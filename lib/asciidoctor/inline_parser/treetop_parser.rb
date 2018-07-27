require 'polyglot'
require 'treetop'

require './lib/asciidoctor/inline_parser/asciidoctor_grammar'

module Asciidoctor

  module InlineParser
    @parser = AsciidoctorGrammarParser.new

    def self.parse text
      @parser.parse text
    end
  end
end
