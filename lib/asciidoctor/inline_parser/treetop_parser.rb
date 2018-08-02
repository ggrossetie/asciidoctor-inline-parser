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

    def self.recurse node
      return if node.elements.nil?
      node.elements.each do |el|
        if el.class.name == 'AsciidoctorGrammar::StrongQuoted'
          ast = parse el.content
          assign_node ast, el unless ast.nil?
        end
        recurse el
      end
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
