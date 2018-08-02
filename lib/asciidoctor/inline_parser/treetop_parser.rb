require 'polyglot'
require 'treetop'

require File.join __dir__, 'node_extensions.rb'

require './lib/asciidoctor/inline_parser/asciidoctor_grammar'

module Asciidoctor
  # Asciodoctor Inline Parser
  module InlineParser
    @parser = AsciidoctorGrammarParser.new

    def self.parse text
      ast = @parser.parse text
      return ast if ast.nil?
      clean_tree ast
      recurse ast
      ast
    end

    def self.recurse root_node
      return if root_node.elements.nil?
      root_node.elements.each do |node|
        if node.class.name == 'AsciidoctorGrammar::StrongQuoted'
          ast = parse node.content
          assign_node ast, node unless ast.nil?
        end
        recurse node
      end
    end

    def self.clean_tree root_node
      return if root_node.elements.nil?
      root_node.elements.delete_if { |node| node.class.name == 'Treetop::Runtime::SyntaxNode' }
      root_node.elements.each { |node| clean_tree node }
    end

    def self.assign_node root, node
      node.elements.clear
      root.parent = node
      node.elements << root
    end
  end
end
