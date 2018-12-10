require 'treetop/runtime'

require_relative 'node_extensions'
require_relative 'mapper'
require_relative 'asciidoctor_grammar'

module Asciidoctor
  # Asciidoctor Inline Parser
  module InlineParser
    @parser = ::AsciidoctorGrammarParser.new

    def self.parse text, raw = false
      # HACK: Use the following rule to parse a literal line.
      # Is it possible to implement the following Treetop rule: "when the line is indented with one or more spaces" ?
      # Since Treetop consumes the input, a given rule doesn't know if a matching space is at the start of the line.
      if text.start_with? ' '
        text = text.strip
        return ::AsciidoctorGrammar::LiteralLine.new text, 0..text.length
      end
      ast = @parser.parse text
      return ast if ast.nil?
      clean_tree ast unless raw
      recurse ast
      ast
    end

    def self.raw_parse text
      parse text, true
    end

    def self.recurse node
      return if node.elements.nil?
      node.elements.each do |el|
        if quoted_node? el
          ast = parse el.content
          assign_node ast, el unless ast.nil?
        end
        recurse el
      end
    end

    def self.quoted_node? node
      node.class.ancestors.include? ::AsciidoctorGrammar::QuotedNode
    end

    def self.clean_tree node
      return if node.elements.nil?
      node.elements.delete_if { |el| el.class.name == 'Treetop::Runtime::SyntaxNode' }
      node.elements.each { |el| clean_tree el }
    end

    def self.assign_node parent, node
      node.elements.clear
      parent.parent = node
      node.elements << parent
    end
  end
end
