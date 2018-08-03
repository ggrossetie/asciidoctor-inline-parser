require_relative 'test_helper'
require 'asciidoctor'
require 'asciidoctor/inline_parser/treetop_parser'

describe 'InlineParser' do
  it 'must parse a bold statement' do
    ast = ::Asciidoctor::InlineParser.parse('This is a *bold* statement.')
    ast.text_value.must_equal 'This is a *bold* statement.'
    mark_nodes = find_by (node_type_must_be 'Strong'), ast
    mark_nodes.size.must_equal 1
    mark_nodes.first.text_value.must_equal '*bold*'
  end
  it 'must parse mark' do
    ast = ::Asciidoctor::InlineParser.parse('#Mark my words#')
    ast.text_value.must_equal '#Mark my words#'
    mark_nodes = find_by (node_type_must_be 'Mark'), ast
    mark_nodes.size.must_equal 1
    mark_nodes.first.text_value.must_equal '#Mark my words#'
  end
  it 'must parse monospaced code' do
    ast = ::Asciidoctor::InlineParser.parse('`var i = \'abcd\';`')
    ast.text_value.must_equal '`var i = \'abcd\';`'
    monospaced_nodes = find_by (node_type_must_be 'Monospaced'), ast
    monospaced_nodes.size.must_equal 1
    monospaced_nodes.first.text_value.must_equal '`var i = \'abcd\';`'
  end
  it 'must parse superscript' do
    ast = ::Asciidoctor::InlineParser.parse('E = mc^2^')
    ast.text_value.must_equal 'E = mc^2^'
    superscript_nodes = find_by (node_type_must_be 'Superscript'), ast
    superscript_nodes.size.must_equal 1
    superscript_nodes.first.text_value.must_equal '^2^'
  end
  it 'must parse subscript' do
    ast = ::Asciidoctor::InlineParser.parse('~a~')
    ast.text_value.must_equal '~a~'
    subscript_nodes = find_by (node_type_must_be 'Subscript'), ast
    subscript_nodes.size.must_equal 1
    subscript_nodes.first.text_value.must_equal '~a~'
  end
  it 'must parse monospaced' do
    ast = ::Asciidoctor::InlineParser.parse('Use `/*` and `*/` for multiline comments.')
    ast.text_value.must_equal 'Use `/*` and `*/` for multiline comments.'
    monospaced_nodes = find_by (node_type_must_be 'Monospaced'), ast
    monospaced_nodes.size.must_equal 2
    monospaced_nodes[0].text_value.must_equal '`/*`'
    monospaced_nodes[1].text_value.must_equal '`*/`'
  end
  it 'must parse nested quoted' do
    ast = ::Asciidoctor::InlineParser.parse('The next *few words are _really_ important!*')
    ast.text_value.must_equal 'The next *few words are _really_ important!*'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 1
    strong_nodes.first.text_value.must_equal '*few words are _really_ important!*'
    emphasis_nodes = find_by (node_type_must_be 'Emphasis'), ast
    emphasis_nodes.size.must_equal 1
  end
  it 'must parse an emphasis' do
    ast = ::Asciidoctor::InlineParser.parse('The parser is working _99%_ of the time')
    ast.text_value.must_equal 'The parser is working _99%_ of the time'
    emphasis_nodes = find_by (node_type_must_be 'Emphasis'), ast
    emphasis_nodes.size.must_equal 1
    emphasis_nodes.first.text_value.must_equal '_99%_'
    emphasis_nodes.first.content.must_equal '99%'
  end
  it 'must parse an emphasis' do
    ast = ::Asciidoctor::InlineParser.parse('few words are _really_ important!')
    ast.text_value.must_equal 'few words are _really_ important!'
    emphasis_nodes = find_by (node_type_must_be 'Emphasis'), ast
    emphasis_nodes.size.must_equal 1
    emphasis_nodes.first.text_value.must_equal '_really_'
  end
  it 'must not match an emphasis' do
    ast = ::Asciidoctor::InlineParser.parse('*_id* word_')
    ast.text_value.must_equal '*_id* word_'
    emphasis_nodes = find_by (node_type_must_be 'Emphasis'), ast
    emphasis_nodes.size.must_equal 0
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 1
    strong_nodes.first.content.must_equal '_id'
  end
  it 'must not match a bold' do
    ast = ::Asciidoctor::InlineParser.parse('Escaped star symbol will not produce \*bold*.')
    ast.text_value.must_equal 'Escaped star symbol will not produce \*bold*.'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 0
  end
end
