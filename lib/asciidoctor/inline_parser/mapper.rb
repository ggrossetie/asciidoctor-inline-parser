require_relative 'inline_node'

# rubocop:disable all
module Asciidoctor
  module InlineParser

    CLASSES_MAPPER = {
      'AsciidoctorGrammar::StrongQuoted' => 'Strong',
      'AsciidoctorGrammar::EmphasisQuoted' => 'Emphasis',
      'AsciidoctorGrammar::MarkQuoted' => 'Mark',
      'AsciidoctorGrammar::MonospacedQuoted' => 'Code',
      'AsciidoctorGrammar::SuperscriptQuoted' => 'Superscript',
      'AsciidoctorGrammar::SubscriptQuoted' => 'Subscript',
      'AsciidoctorEmailGrammar::Email' => 'Email',
      'AsciidoctorEmailGrammar::EmailMacro' => 'Email',
      'AsciidoctorGrammar::DoubleCurvedQuoted' => 'DoubleQuotation',
      'AsciidoctorGrammar::SingleCurvedQuoted' => 'SingleQuotation',
      'AsciidoctorLinkGrammar::Link' => 'Anchor',
      'AsciidoctorKbdGrammar::Kbd' => 'Keyboard',
    }

    # Map a Treetop AST to an Asciidoctor AST
    module Mapper
      def self.map ast
        agg = []
        map_tree ast, agg
        agg
      end

      def self.map_tree node, agg, parent = nil
        return if node.elements.nil?
        if node.class.name == 'AsciidoctorGrammar::Expression' || node.class.name == 'AsciidoctorGrammar::QuotedContent'
          unless node.elements.empty?
            text_source = ''
            node.instance_variable_get('@elements').each { |el|
              if el.class.name == 'Treetop::Runtime::SyntaxNode'
                text_source << el.text_value
              else
                unless text_source.empty?
                  text_node = Text.new
                  text_node.source = text_source
                  if parent
                    text_node.parent = parent
                    parent.children << text_node
                  else
                    agg << text_node
                  end
                end
                text_source = ''
                map_tree el, agg, parent
              end
            }
            unless text_source.empty?
              text_node = Text.new
              text_node.source = text_source
              if parent
                text_node.parent = parent
                parent.children << text_node
              else
                agg << text_node
              end
            end
          end
        elsif (clazz = CLASSES_MAPPER[node.class.name])
          inline_node = Object.const_get("::Asciidoctor::InlineParser::#{clazz}").new
          inline_node.source = node.text_value
          if node.class.name == 'AsciidoctorEmailGrammar::Email'
            inline_node.text = inline_node.target = inline_node.link = inline_node.source
          elsif node.class.name == 'AsciidoctorEmailGrammar::EmailMacro'
            inline_node.text = inline_node.target = node.elements[1].text_value
            inline_node.link = node.name
            inline_node.subject = node.subject
            inline_node.body = node.body
          elsif node.class.name == 'AsciidoctorLinkGrammar::Link'
            inline_node.text = inline_node.target = node.target
            inline_node.link = node.text
            inline_node.roles = node.roles
          elsif node.class.name == 'AsciidoctorKbdGrammar::Kbd'
            inline_node.text = node.elements[1].text_value
            inline_node.keys = node.keys
          else
            inline_node.text = node.instance_variable_get('@comprehensive_elements').first.text_value
          end
          if parent
            inline_node.parent = parent
            parent.children << inline_node
          else
            agg << inline_node
          end
          node.elements.each { |el| map_tree el, agg, inline_node }
        else
          node.elements.each { |el| map_tree el, agg, parent }
        end
      end
    end
  end
end
# rubocop:enable all
