# Asciidoctor
module Asciidoctor
  # Public: Methods to perform substitutions on lines of AsciiDoc text.
  module Subs
    SPECIAL_CHARS_RX = /[<&>]/
    SPECIAL_CHARS_TR = { '>' => '&gt;', '<' => '&lt;', '&' => '&amp;' }.freeze
    REPLACEABLE_TEXT_RX = /[&']|--|\.\.\.|\([CRT]M?\)/

    if ::RUBY_MIN_VERSION_1_9
      CAN = %(\u0018).freeze
      DEL = %(\u007f).freeze

      # Delimiters and matchers for the passthrough placeholder
      # See http://www.aivosto.com/vbtips/control-characters.html#listabout for characters to use

      # SPA, start of guarded protected area (\u0096)
      PASS_START = %(\u0096).freeze

      # EPA, end of guarded protected area (\u0097)
      PASS_END = %(\u0097).freeze
    else
      CAN = 24.chr
      DEL = 127.chr
      PASS_START = 150.chr
      PASS_END = 151.chr
    end

    RS = '\\'.freeze

    class << self
      # Public: Substitute special characters (i.e., encode XML)
      #
      # The special characters <, &, and > get replaced with &lt;,
      # &amp;, and &gt;, respectively.
      #
      # text - The String text to process.
      #
      # returns The String text with special characters replaced.
      if ::RUBY_MIN_VERSION_1_9
        def sub_specialchars text
          if (text.include? '<') || (text.include? '&') || (text.include? '>')
            (text.gsub SPECIAL_CHARS_RX, SPECIAL_CHARS_TR)
          else
            text
          end
        end
      else
        def sub_specialchars text
          if (text.include? '<') || (text.include? '&') || (text.include? '>')
            (text.gsub(SPECIAL_CHARS_RX) { SPECIAL_CHARS_TR[$&] })
          else
            text
          end
        end
      end
      alias sub_specialcharacters sub_specialchars

      # Public: Substitutes attribute references in the specified text
      #
      # Attribute references are in the format +{name}+.
      #
      # If an attribute referenced in the line is missing or undefined, the line may be dropped
      # based on the attribute-missing or attribute-undefined setting, respectively.
      #
      # text - The String text to process
      # doc   - the Document being parsed
      # opts - A Hash of options to control processing: (default: {})
      #        * :attribute_missing controls how to handle a missing attribute
      #
      # Returns the [String] text with the attribute references replaced with resolved values

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/BlockLength
      # rubocop:disable Metrics/PerceivedComplexity
      def sub_attributes text, doc = nil, opts = {}
        doc_attrs = doc.attributes
        drop = drop_line = drop_empty_line = nil
        attribute_undefined ||= doc_attrs['attribute-undefined'] || 'drop-line'
        attribute_missing ||= opts[:attribute_missing] || doc_attrs['attribute-missing'] || 'skip'
        result = text.gsub AttributeReferenceRx do
          # escaped attribute, return unescaped
          if Regexp.last_match(1) == RS || Regexp.last_match(4) == RS
            %({#{Regexp.last_match(2)}})
          elsif Regexp.last_match(3)
            case (args = Regexp.last_match(2).split ':', 3).shift
            when 'set'
              _, value = Parser.store_attribute args[0], args[1] || '', doc
              # NOTE since this is an assignment, only drop-line applies here (skip and drop imply the same result)
              drop = if value || attribute_undefined != 'drop-line'
                       drop_empty_line = DEL
                     else
                       drop_line = CAN
                     end
            when 'counter2'
              doc.counter(*args)
              drop = drop_empty_line = DEL
            else # 'counter'
              doc.counter(*args)
            end
          elsif doc_attrs.key?((key = Regexp.last_match(2).downcase))
            doc_attrs[key]
          elsif (value = INTRINSIC_ATTRIBUTES[key])
            value
          else
            case attribute_missing
            when 'drop'
              drop = drop_empty_line = DEL
            when 'drop-line'
              logger.warn %(dropping line containing reference to missing attribute: #{key})
              drop = drop_line = CAN
            when 'warn'
              logger.warn %(skipping reference to missing attribute: #{key})
              $&
            else # 'skip'
              $&
            end
          end
        end

        if drop
          # drop lines from result
          if drop_empty_line
            lines = (result.tr_s DEL, DEL).split LF, -1
            if drop_line
              (lines.reject do |line|
                line == DEL || line == CAN || (line.start_with? CAN) || (line.include? CAN)
              end.join LF).delete DEL
            else
              (lines.reject { |line| line == DEL }.join LF).delete DEL
            end
          elsif result.include? LF
            (result.split LF, -1).reject { |line| line == CAN || (line.start_with? CAN) || (line.include? CAN) }.join LF
          else
            ''
          end
        else
          result
        end
      end

      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/BlockLength
      # rubocop:enable Metrics/PerceivedComplexity

      if RUBY_ENGINE == 'opal'
        def sub_replacements text
          if REPLACEABLE_TEXT_RX.match? text
            REPLACEMENTS.each do |pattern, replacement, restore|
              text = text.gsub(pattern) { do_replacement $LAST_MATCH_INFO, replacement, restore }
            end
          end
          text
        end
      else
        # Public: Substitute replacement characters (e.g., copyright, trademark, etc)
        #
        # text - The String text to process
        #
        # returns The String text with the replacement characters substituted
        def sub_replacements text
          if REPLACEABLE_TEXT_RX.match? text
            # NOTE interpolation is faster than String#dup
            text = text.to_s
            REPLACEMENTS.each do |pattern, replacement, restore|
              # NOTE Using gsub! as optimization
              text.gsub!(pattern) { do_replacement $LAST_MATCH_INFO, replacement, restore }
            end
          end
          text
        end
      end

      # Internal: Substitute replacement text for matched location
      #
      # returns The String text with the replacement characters substituted
      def do_replacement match, replacement, restore
        if (captured = match[0]).include? RS
          # we have to use sub since we aren't sure it's the first char
          captured.sub RS, ''
        else
          case restore
          when :none
            replacement
          when :bounding
            %(#{match[1]}#{replacement}#{m[2]})
          else # :leading
            %(#{match[1]}#{replacement})
          end
        end
      end
    end
  end
end
