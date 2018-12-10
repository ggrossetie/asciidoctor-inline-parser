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
          inline_node.text = node.instance_variable_get('@comprehensive_elements').first.text_value
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