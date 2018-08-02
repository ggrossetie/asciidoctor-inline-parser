require 'polyglot'
require 'treetop'

require './lib/asciidoctor/inline_parser/asciidoctor_grammar'

module Asciidoctor
  # Inline Parser
  module InlineParser
    @parser = AsciidoctorGrammarParser.new

    def self.parse text
      @parser.parse text
    end
  end
end
