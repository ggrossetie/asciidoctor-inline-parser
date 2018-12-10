require_relative 'test_helper'
require 'asciidoctor'
require 'asciidoctor/inline_parser/parser'

describe 'mapper' do
  describe 'simple sentence with a constrained and unconstrained strong' do
    it 'should map a constrained strong word' do
      input = 'This is a sentence with a strong *word*'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'This is a sentence with a strong '
      result[1].source.must_equal '*word*'
      result[1].text.must_equal 'word'
      result[1].class.name.must_equal 'Asciidoctor::InlineParser::Strong'
    end
    it 'should map an unconstrained strong letter' do
      input = 'This is a sentence with a strong le**t**ter'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 3
      result.first.source.must_equal 'This is a sentence with a strong le'
      result[1].source.must_equal '**t**'
      result[1].text.must_equal 't'
      result[1].class.name.must_equal 'Asciidoctor::InlineParser::Strong'
      result[2].source.must_equal 'ter'
    end
  end
  describe 'simple sentence with a constrained and unconstrained mark' do
    it 'should map a constrained marked word' do
      input = 'This is a sentence with a marked #word#'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'This is a sentence with a marked '
      result[1].source.must_equal '#word#'
      result[1].text.must_equal 'word'
      result[1].class.name.must_equal 'Asciidoctor::InlineParser::Mark'
    end
    it 'should map an unconstrained marked letter' do
      input = 'This is a sentence with a marked le##t##ter'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 3
      result.first.source.must_equal 'This is a sentence with a marked le'
      result[1].source.must_equal '##t##'
      result[1].text.must_equal 't'
      result[1].class.name.must_equal 'Asciidoctor::InlineParser::Mark'
      result[2].source.must_equal 'ter'
    end
  end
  describe 'simple sentence with a constrained and unconstrained emphasis' do
    it 'should map a constrained emphasis word' do
      input = 'This is a sentence with an emphasis _word_'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'This is a sentence with an emphasis '
      result[1].source.must_equal '_word_'
      result[1].text.must_equal 'word'
      result[1].class.name.must_equal 'Asciidoctor::InlineParser::Emphasis'
    end
    it 'should map an unconstrained emphasis letter' do
      input = 'This is a sentence with an emphasis le__t__ter'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 3
      result.first.source.must_equal 'This is a sentence with an emphasis le'
      result[1].source.must_equal '__t__'
      result[1].text.must_equal 't'
      result[1].class.name.must_equal 'Asciidoctor::InlineParser::Emphasis'
      result[2].source.must_equal 'ter'
    end
  end
  describe 'simple sentence with a constrained and unconstrained monospaced' do
    it 'should map a constrained monospaced word' do
      input = 'This is a sentence with a monospaced `word`'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'This is a sentence with a monospaced '
      result[1].source.must_equal '`word`'
      result[1].text.must_equal 'word'
      result[1].class.name.must_equal 'Asciidoctor::InlineParser::Code'
    end
    it 'should map an unconstrained monospaced letter' do
      input = 'This is a sentence with a monospaced le``t``ter'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 3
      result.first.source.must_equal 'This is a sentence with a monospaced le'
      result[1].source.must_equal '``t``'
      result[1].text.must_equal 't'
      result[1].class.name.must_equal 'Asciidoctor::InlineParser::Code'
      result[2].source.must_equal 'ter'
    end
  end
  it 'should map a simple sentence with a superscript single letter' do
    input = 'This is a famous formula: E = mc^2^'
    ast = ::Asciidoctor::InlineParser.raw_parse input
    result = ::Asciidoctor::InlineParser::Mapper.map ast
    result.size.must_equal 2
    result.first.source.must_equal 'This is a famous formula: E = mc'
    result[1].source.must_equal '^2^'
    result[1].text.must_equal '2'
    result[1].class.name.must_equal 'Asciidoctor::InlineParser::Superscript'
  end
  it 'should map a simple sentence with a subscript single letter' do
    input = 'This is a subscript ~a~'
    ast = ::Asciidoctor::InlineParser.raw_parse input
    result = ::Asciidoctor::InlineParser::Mapper.map ast
    result.size.must_equal 2
    result.first.source.must_equal 'This is a subscript '
    result[1].source.must_equal '~a~'
    result[1].text.must_equal 'a'
    result[1].class.name.must_equal 'Asciidoctor::InlineParser::Subscript'
  end
  describe 'nested' do
    it 'should map a nested formatted string (emphasis text inside a bold text)' do
      input = 'The next *few words are _really_ important!*'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'The next '
      result[1].source.must_equal '*few words are _really_ important!*'
      result[1].text.must_equal 'few words are _really_ important!'
      result[1].class.name.must_equal 'Asciidoctor::InlineParser::Strong'
      result[1].children.size.must_equal 3
      result[1].children.first.source.must_equal 'few words are '
      result[1].children[1].source.must_equal '_really_'
      result[1].children[1].text.must_equal 'really'
      result[1].children[1].class.name.must_equal 'Asciidoctor::InlineParser::Emphasis'
      result[1].children[2].source.must_equal ' important!'
    end
  end
end
