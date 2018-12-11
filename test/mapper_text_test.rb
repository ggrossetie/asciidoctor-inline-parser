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
  describe 'email' do
    it 'should map an implicit email' do
      input = 'Here is my email address: doc.writer@asciidoc.org.'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 3
      result.first.source.must_equal 'Here is my email address: '
      result[1].source.must_equal 'doc.writer@asciidoc.org'
      result[1].text.must_equal 'doc.writer@asciidoc.org'
      result[1].target.must_equal 'doc.writer@asciidoc.org'
      result[1].link.must_equal 'doc.writer@asciidoc.org'
      result[1].subject.must_be_nil
      result[2].source.must_equal '.'
    end
    it 'should map an explicit email' do
      input = 'If you want to know more about the mailto macro, send me an email at mailto:doc.writer@asciidoc.org[]!'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 3
      result.first.source.must_equal 'If you want to know more about the mailto macro, send me an email at '
      result[1].source.must_equal 'mailto:doc.writer@asciidoc.org[]'
      result[1].text.must_equal 'doc.writer@asciidoc.org'
      result[1].target.must_equal 'doc.writer@asciidoc.org'
      result[1].link.must_equal 'doc.writer@asciidoc.org'
      result[1].subject.must_be_nil
      result[2].source.must_equal '!'
    end
    it 'should map a link' do
      input = 'mailto:doc.writer@asciidoc.org[Doc Writer]'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 1
      result.first.source.must_equal 'mailto:doc.writer@asciidoc.org[Doc Writer]'
      result.first.text.must_equal 'doc.writer@asciidoc.org'
      result.first.target.must_equal 'doc.writer@asciidoc.org'
      result.first.link.must_equal 'Doc Writer'
      result.first.subject.must_be_nil
    end
    it 'should map an explicit email with subject' do
      input = 'Write me about pull request at: mailto:doc.writer@asciidoc.org[Doc Writer, Pull request]'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'Write me about pull request at: '
      result[1].source.must_equal 'mailto:doc.writer@asciidoc.org[Doc Writer, Pull request]'
      result[1].text.must_equal 'doc.writer@asciidoc.org'
      result[1].target.must_equal 'doc.writer@asciidoc.org'
      result[1].link.must_equal 'Doc Writer'
      result[1].subject.must_equal 'Pull request'
    end
    it 'should map an explicit email with a subject and a body' do
      input = 'mailto:doc.writer@asciidoc.org[Doc Writer, Pull request, Please accept my pull request]'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 1
      result.first.source.must_equal 'mailto:doc.writer@asciidoc.org[Doc Writer, Pull request, Please accept my pull request]'
      result.first.text.must_equal 'doc.writer@asciidoc.org'
      result.first.target.must_equal 'doc.writer@asciidoc.org'
      result.first.link.must_equal 'Doc Writer'
      result.first.subject.must_equal 'Pull request'
      result.first.body.must_equal 'Please accept my pull request'
    end
  end

  describe 'quotation' do
    it 'should map double quotation' do
      input = '"`double curved quotes`"'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 1
      result.first.source.must_equal '"`double curved quotes`"'
      result.first.text.must_equal 'double curved quotes'
      result.first.class.name.must_equal 'Asciidoctor::InlineParser::DoubleQuotation'
    end
    it 'should map single quotation' do
      input = '\'`single curved quotes`\''
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 1
      result.first.source.must_equal '\'`single curved quotes`\''
      result.first.text.must_equal 'single curved quotes'
      result.first.class.name.must_equal 'Asciidoctor::InlineParser::SingleQuotation'
    end
  end
end
