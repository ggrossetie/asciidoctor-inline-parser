require_relative 'test_helper'
require 'asciidoctor'
require 'asciidoctor/inline_parser/treetop_parser'

describe "InlineParser" do
  it "must parse a bold statement" do
    ast = ::Asciidoctor::InlineParser.parse('This is a *bold* statement.')
    ast.elements {|node| node.klass == "SyntaxNode+Strong0"}.size.must_equal 1
    ast.text_value.must_equal 'This is a *bold* statement.'
  end
  it "must parse mark" do
    ast = ::Asciidoctor::InlineParser.parse('#Mark my words#')
    ast.elements {|node| node.klass == "SyntaxNode+Mark0"}.size.must_equal 1
    ast.text_value.must_equal '#Mark my words#'
  end
  it "must parse monospaced code" do
    ast = ::Asciidoctor::InlineParser.parse('`var i = "abcd";`')
    ast.elements {|node| node.klass == "SyntaxNode+Monospaced0"}.size.must_equal 1
    ast.text_value.must_equal '`var i = "abcd";`'
  end
  it "must parse superscript" do
    ast = ::Asciidoctor::InlineParser.parse('E = mc^2^')
    ast.elements {|node| node.klass == "SyntaxNode+Superscript0"}.size.must_equal 1
    ast.text_value.must_equal 'E = mc^2^'
  end
  it "must parse subscript" do
    ast = ::Asciidoctor::InlineParser.parse('~a~')
    ast.elements {|node| node.klass == "SyntaxNode+Subscript0"}.size.must_equal 1
    ast.text_value.must_equal '~a~'
  end
  it "must parse monospaced" do
    ast = ::Asciidoctor::InlineParser.parse('Use `/*` and `*/` for multiline comments.')
    ast.elements {|node| node.klass == "SyntaxNode+Monospaced0"}.size.must_equal 2
    ast.text_value.must_equal 'Use `/*` and `*/` for multiline comments.'
  end
  it "must parse nested quoted" do
    ast = ::Asciidoctor::InlineParser.parse('The next *few words are _really_ important!*')
    ast.elements {|node| node.klass == "SyntaxNode+Strong0"}.size.must_equal 1
    # TODO Nested is not working!
    #ast.elements{ |node| node.klass == "SyntaxNode+Emphasis0" }.size.must_equal 1
    ast.text_value.must_equal 'The next *few words are _really_ important!*'
  end
  it "must parse an emphasis" do
    ast = ::Asciidoctor::InlineParser.parse('The parser is working _99%_ of the time')
    ast.elements {|node| node.klass == "SyntaxNode+Emphasis0"}.size.must_equal 1
    ast.text_value.must_equal 'The parser is working _99%_ of the time'
  end
end
