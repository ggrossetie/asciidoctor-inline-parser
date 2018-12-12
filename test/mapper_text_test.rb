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
      result[1].address.must_equal 'doc.writer@asciidoc.org'
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
      result[1].address.must_equal 'doc.writer@asciidoc.org'
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
      result.first.address.must_equal 'doc.writer@asciidoc.org'
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
      result[1].address.must_equal 'doc.writer@asciidoc.org'
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
      result.first.address.must_equal 'doc.writer@asciidoc.org'
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

  describe 'link' do
    it 'should map a bare link' do
      input = 'The AsciiDoc project is located at http://asciidoc.org.'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 3
      result.first.source.must_equal 'The AsciiDoc project is located at '
      result.first.class.name.must_equal 'Asciidoctor::InlineParser::Text'
      result[1].source.must_equal 'http://asciidoc.org'
      result[1].text.must_equal 'http://asciidoc.org'
      result[1].roles.must_include 'bare'
      result[1].class.name.must_equal 'Asciidoctor::InlineParser::Anchor'
      result[2].source.must_equal '.'
      result[2].class.name.must_equal 'Asciidoctor::InlineParser::Text'
    end
  end

  describe 'keyboard' do
    it 'should map kbd macro' do
      input = 'Toggle fullscreen: kbd:[F11]'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'Toggle fullscreen: '
      result[1].source.must_equal 'kbd:[F11]'
      result[1].text.must_equal 'F11'
      result[1].keys.must_include 'F11'
    end

    it 'should map kbd macro with a combination of 3 keys' do
      input = 'New incognito window: kbd:[Ctrl+Shift+N]'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'New incognito window: '
      result[1].source.must_equal 'kbd:[Ctrl+Shift+N]'
      result[1].text.must_equal 'Ctrl+Shift+N'
      result[1].keys.size.must_equal 3
      result[1].keys.must_include 'Ctrl'
      result[1].keys.must_include 'Shift'
      result[1].keys.must_include 'N'
    end

    it 'should map kbd macro with a plus key' do
      input = 'Increase zoom: kbd:[Ctrl + +]'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'Increase zoom: '
      result[1].source.must_equal 'kbd:[Ctrl + +]'
      result[1].text.must_equal 'Ctrl + +'
      result[1].keys.size.must_equal 2
      result[1].keys.must_include 'Ctrl'
      result[1].keys.must_include '+'
    end

    it 'should map kdb macro with an escaped closed bracket' do
      input = 'Jump to keyword: kbd:[Ctrl+\]]'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'Jump to keyword: '
      result[1].source.must_equal 'kbd:[Ctrl+\]]'
      result[1].text.must_equal 'Ctrl+\]'
      result[1].keys.size.must_equal 2
      result[1].keys.must_include 'Ctrl'
      result[1].keys.must_include ']'
    end
  end

  describe 'image' do
    it 'should map an image with name and title' do
      input = 'Click image:icons/play.png[Play icon, title="Play"] to get the party started.'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 3
      result.first.source.must_equal 'Click '
      result[1].source.must_equal 'image:icons/play.png[Play icon, title="Play"]'
      result[1].text.must_equal 'Play icon'
      result[1].target.must_equal 'icons/play.png'
      result[1].title.must_equal 'Play'
      result[1].alt.must_equal 'Play icon'
      result[2].source.must_equal ' to get the party started.'
    end

    it 'should map an image with a positioning role, width, height and alt' do
      input =  'image:sunset.jpg[Sunset,200,150,role="right"] What a beautiful sunset!'
      ast = ::Asciidoctor::InlineParser.raw_parse input
      result = ::Asciidoctor::InlineParser::Mapper.map ast
      result.size.must_equal 2
      result.first.source.must_equal 'image:sunset.jpg[Sunset,200,150,role="right"]'
      result.first.text.must_equal 'Sunset'
      result.first.target.must_equal 'sunset.jpg'
      result.first.title.must_equal nil
      result.first.alt.must_equal 'Sunset'
      result.first.width.must_equal '200'
      result.first.height.must_equal '150'
      result.first.roles.size.must_equal 2
      result.first.roles.must_include 'right'
      result.first.roles.must_include 'image' # QUESTION should we remove this default role named "image" (converter concern ?)
      result[1].source.must_equal ' What a beautiful sunset!'
    end
  end
end
