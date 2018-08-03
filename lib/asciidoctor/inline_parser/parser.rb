require 'treetop/runtime'

require_relative 'node_extensions.rb'
require_relative 'asciidoctor_grammar.rb' # generated

module Asciidoctor
  # Asciidoctor Inline Parser
  module InlineParser
    @parser = ::AsciidoctorGrammarParser.new

    def self.parse text
      ast = @parser.parse text
      return ast if ast.nil?
      clean_tree ast
      recurse ast
      ast
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
