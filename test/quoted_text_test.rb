require_relative 'test_helper'
require 'asciidoctor'
require 'asciidoctor/inline_parser/parser'

describe 'quoted text' do
  quotes = [
    # *strong* (constrained) or **strong** (unconstrained)
    { name: :strong, symbol: '*', type: 'Strong' },

    # `monospaced` (constrained) or ``monospaced`` (unconstrained)
    { name: :monospaced, symbol: '`', type: 'Monospaced' },

    # _emphasis_ (constrained) or __emphasis__ (unconstrained)
    { name: :emphasis, symbol: '_', type: 'Emphasis' },

    # #mark# (constrained) ##mark## (unconstrained)
    { name: :mark, symbol: '#', type: 'Mark' }
  ]
  constrained_quotes = quotes + [
    # ^superscript^ (constrained)
    { name: :superscript, symbol: '^', type: 'Superscript' },
    # ~subscript~ (constrained)
    { name: :subscript, symbol: '~', type: 'Subscript' }
  ]

  constrained_quotes.each do |constrained_quote|
    name = constrained_quote[:name]
    symbol = constrained_quote[:symbol]
    type = constrained_quote[:type]
    describe "constrained #{name}" do
      it 'should parse a single-line constrained word' do
        input = %(#{symbol}word#{symbol})
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 1
        nodes.first.text_value.must_equal input
        nodes.first.content.must_equal 'word'
      end
      it 'should parse a single-line constrained string' do
        input = %(#{symbol}a few words#{symbol})
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 1
        nodes.first.text_value.must_equal input
        nodes.first.content.must_equal 'a few words'
      end
      it 'should parse a single-line constrained string in a sentence' do
        input = "I want to say #{symbol}a few words#{symbol}."
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 1
        nodes.first.text_value.must_equal "#{symbol}a few words#{symbol}"
        nodes.first.content.must_equal 'a few words'
      end
      it 'should parse an escaped single-line constrained string' do
        input = "#{BACKSLASH}#{symbol}a few words#{symbol}"
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 0
      end
      it 'should parse a multi-line constrained string' do
        input = "#{symbol}a few\nwords#{symbol}"
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 1
        nodes.first.text_value.must_equal input
        nodes.first.content.must_equal %(a few\nwords)
      end
    end
  end

  quotes.each do |unconstrained_quote|
    name = unconstrained_quote[:name]
    symbol = unconstrained_quote[:symbol]
    type = unconstrained_quote[:type]
    describe "unconstrained #{name}" do
      it 'should parse a single-line constrained word' do
        input = %(#{symbol}word#{symbol})
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 1
        nodes.first.text_value.must_equal input
        nodes.first.content.must_equal 'word'
      end
      it 'should parse a single-line constrained string' do
        input = %(#{symbol}a few words#{symbol})
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 1
        nodes.first.text_value.must_equal input
        nodes.first.content.must_equal 'a few words'
      end
      it 'should parse a single-line constrained string in a sentence' do
        input = "I want to say #{symbol}a few words#{symbol}."
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 1
        nodes.first.text_value.must_equal "#{symbol}a few words#{symbol}"
        nodes.first.content.must_equal 'a few words'
      end
      it 'should parse an escaped single-line constrained string' do
        input = "#{BACKSLASH}#{symbol}a few words#{symbol}"
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 0
      end
      it 'should parse a multi-line constrained string' do
        input = "#{symbol}a few\nwords#{symbol}"
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 1
        nodes.first.text_value.must_equal input
        nodes.first.content.must_equal %(a few\nwords)
      end
      it 'should not parse a constrained string with a number directly outside the formatting marks' do
        input = "E = #{symbol}mc#{symbol}2"
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 0
      end
      it 'should parse a constrained string with a colon directly before the starting formatting mark' do
        input = "There's a colon:#{symbol}directly#{symbol} before the starting formatting mark."
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 1
        nodes.first.text_value.must_equal "#{symbol}directly#{symbol}"
        nodes.first.content.must_equal 'directly'
      end
      it 'should parse a constrained string with a semi-colon directly before the starting formatting mark' do
        input = "There's a semi-colon directly before the starting formatting mark &ndash;#{symbol}2018#{symbol}"
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.first.text_value.must_equal "#{symbol}2018#{symbol}"
        nodes.first.content.must_equal '2018'
      end
      it 'should parse a constrained string with a closing curly bracket directly before the starting formatting mark' do
        input = "There's a closing curly bracket directly {before}#{symbol}the starting formatting mark#{symbol}."
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.first.text_value.must_equal "#{symbol}the starting formatting mark#{symbol}"
        nodes.first.content.must_equal 'the starting formatting mark'
      end
      ## Constrained quote limitations
      # there's a letter directly outside the formatting marks
      it 'should parse a constrained string with a letter directly outside the formatting marks' do
        input = "There's a l#{symbol}e#{symbol}tter directly outside the formatting marks."
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 0
      end
      # there's a space directly inside of the formatting mark
      it 'should parse a constrained string with inner spaces' do
        input = "There's a #{symbol} space #{symbol} directly inside of the formatting mark"
        ast = ::Asciidoctor::InlineParser.parse input
        ast.text_value.must_equal input
        nodes = find_by (node_type_must_be type), ast
        nodes.size.must_equal 0
      end
    end
  end
end
