require_relative 'test_helper'
require 'asciidoctor'
require 'asciidoctor/inline_parser/treetop_parser'

BACKSLASH = %(\x5c).freeze

describe 'InlineParser' do
  it 'should parse a single-line constrained marked string' do
    ast = ::Asciidoctor::InlineParser.parse '#a few words#'
    ast.text_value.must_equal '#a few words#'
    nodes = find_by (node_type_must_be 'Mark'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '#a few words#'
    nodes.first.content.must_equal 'a few words'
  end
  it 'should parse an escaped single-line constrained marked string' do
    ast = ::Asciidoctor::InlineParser.parse %(#{BACKSLASH}#a few words#)
    ast.text_value.must_equal '\#a few words#'
    nodes = find_by (node_type_must_be 'Mark'), ast
    nodes.size.must_equal 0
  end
  it 'should parse a multi-line constrained marked string' do
    ast = ::Asciidoctor::InlineParser.parse %(#a few\nwords#)
    ast.text_value.must_equal %(#a few\nwords#)
    nodes = find_by (node_type_must_be 'Mark'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal %(#a few\nwords#)
    nodes.first.content.must_equal %(a few\nwords)
  end
  it 'should parse a single-line unconstrained marked string' do
    ast = ::Asciidoctor::InlineParser.parse %(##--anything goes ##)
    ast.text_value.must_equal %(##--anything goes ##)
    nodes = find_by (node_type_must_be 'UnconstrainedMark'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal %(##--anything goes ##)
    nodes.first.content.must_equal %(--anything goes )
  end
  it 'should parse an escaped single-line unconstrained marked string' do
    ast = ::Asciidoctor::InlineParser.parse %(#{BACKSLASH}#{BACKSLASH}##--anything goes ##)
    ast.text_value.must_equal %(#{BACKSLASH}#{BACKSLASH}##--anything goes ##)
    nodes = find_by (node_type_must_be 'UnconstrainedMark'), ast
    nodes.size.must_equal 0
  end
  it 'should parse a single-line constrained marked string with role' do
    # FIXME: marked string with role are not yet supported
    skip 'marked string with role are not yet supported'
    ast = ::Asciidoctor::InlineParser.parse '[statement]#a few words#'
    ast.text_value.must_equal '[statement]#a few words#'
    # expected result: <span class="statement">a few words</span>
  end
  it 'should parse a single-line constrained strong string' do
    ast = ::Asciidoctor::InlineParser.parse '*a few strong words*'
    ast.text_value.must_equal '*a few strong words*'
    nodes = find_by (node_type_must_be 'Strong'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '*a few strong words*'
    nodes.first.content.must_equal 'a few strong words'
  end
  it 'should parse a escaped single-line constrained strong string' do
    ast = ::Asciidoctor::InlineParser.parse %(#{BACKSLASH}*a few strong words*)
    ast.text_value.must_equal %(#{BACKSLASH}*a few strong words*)
    nodes = find_by (node_type_must_be 'Strong'), ast
    nodes.size.must_equal 0
  end
  it 'should parse a multi-line constrained strong string' do
    ast = ::Asciidoctor::InlineParser.parse "*a few\nstrong words*"
    ast.text_value.must_equal "*a few\nstrong words*"
    nodes = find_by (node_type_must_be 'Strong'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal "*a few\nstrong words*"
    nodes.first.content.must_equal "a few\nstrong words"
  end
  it 'should parse a constrained strong string containing an asterisk' do
    ast = ::Asciidoctor::InlineParser.parse '*bl*ck*-eye'
    ast.text_value.must_equal '*bl*ck*-eye'
    nodes = find_by (node_type_must_be 'Strong'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '*bl*ck*'
    nodes.first.content.must_equal 'bl*ck'
  end
  it 'should parse a constrained strong string containing an asterisk and multibyte word chars' do
    # FIXME: multibyte word chars are not yet supported
    skip 'multibyte word chars are not yet supported'
    ast = ::Asciidoctor::InlineParser.parse '*黑*眼圈*'
    ast.text_value.must_equal '*黑*眼圈*'
    nodes = find_by (node_type_must_be 'Strong'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '*黑*眼圈*'
    nodes.first.content.must_equal '黑*眼圈'
  end
  it 'should parse a single-line constrained quote variation emphasized string' do
    ast = ::Asciidoctor::InlineParser.parse '_a few emphasized words_'
    ast.text_value.must_equal '_a few emphasized words_'
    nodes = find_by (node_type_must_be 'Emphasis'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '_a few emphasized words_'
    nodes.first.content.must_equal 'a few emphasized words'
  end
  it 'should parse an escaped single-line constrained quote variation emphasized string' do
    ast = ::Asciidoctor::InlineParser.parse %(#{BACKSLASH}_a few emphasized words_)
    ast.text_value.must_equal %(#{BACKSLASH}_a few emphasized words_)
    nodes = find_by (node_type_must_be 'Emphasis'), ast
    nodes.size.must_equal 0
  end
  it 'should parse a multi-line constrained emphasized quote variation string' do
    ast = ::Asciidoctor::InlineParser.parse "_a few\nemphasized words_"
    ast.text_value.must_equal "_a few\nemphasized words_"
    nodes = find_by (node_type_must_be 'Emphasis'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal "_a few\nemphasized words_"
    nodes.first.content.must_equal "a few\nemphasized words"
  end
  it 'should parse a single-line unconstrained strong chars' do
    ast = ::Asciidoctor::InlineParser.parse '**Git**Hub'
    ast.text_value.must_equal '**Git**Hub'
    nodes = find_by (node_type_must_be 'UnconstrainedStrong'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '**Git**'
    nodes.first.content.must_equal 'Git'
  end
  it 'should parse a multi-line unconstrained strong chars' do
    ast = ::Asciidoctor::InlineParser.parse "**G\ni\nt\n**Hub"
    ast.text_value.must_equal "**G\ni\nt\n**Hub"
    nodes = find_by (node_type_must_be 'UnconstrainedStrong'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal "**G\ni\nt\n**"
    nodes.first.content.must_equal "G\ni\nt\n"
  end
  it 'should parse a unconstrained strong chars with inline asterisk' do
    ast = ::Asciidoctor::InlineParser.parse '**bl*ck**-eye'
    ast.text_value.must_equal '**bl*ck**-eye'
    nodes = find_by (node_type_must_be 'UnconstrainedStrong'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '**bl*ck**'
    nodes.first.content.must_equal 'bl*ck'
  end
  it 'should parse a unconstrained strong chars with role' do
    # FIXME: strong chars with role are not yet supported
    skip 'strong chars with role are not yet supported'
    ast = ::Asciidoctor::InlineParser.parse 'Git[blue]**Hub**'
    ast.text_value.must_equal 'Git[blue]**Hub**'
    # expected result: %q{Git<strong class="blue">Hub</strong>}
  end
  # REMIND: this is not the same result as AsciiDoc, though I don't understand why AsciiDoc gets what it gets
  it 'should parse a escaped unconstrained strong chars with role' do
    # FIXME: escaped unconstrained strong chars with role are not yet supported
    skip 'escaped unconstrained strong chars with role are not yet supported'
    ast = ::Asciidoctor::InlineParser.parse %(Git#{BACKSLASH}[blue]**Hub**)
    ast.text_value.must_equal %(Git#{BACKSLASH}[blue]**Hub**)
    # expected result: %q{Git[blue]<strong>*Hub</strong>*}
  end
  it 'should parse a single-line unconstrained emphasized chars' do
    ast = ::Asciidoctor::InlineParser.parse '__Git__Hub'
    ast.text_value.must_equal '__Git__Hub'
    nodes = find_by (node_type_must_be 'UnconstrainedEmphasis'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '__Git__'
    nodes.first.content.must_equal 'Git'
  end
  it 'should parse an escaped single-line unconstrained strong chars' do
    # FIXME: Unexpected result, let's discuss it!
    skip 'Unexpected result. I would expect \**Git**Hub to be equivalent to *Git**Hub (with a trailing *)'
    ast = ::Asciidoctor::InlineParser.parse %(#{BACKSLASH}**Git**Hub)
    ast.text_value.must_equal %(#{BACKSLASH}**Git**Hub)
    nodes = find_by (node_type_must_be 'UnconstrainedStrong'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '**Git*'
    nodes.first.content.must_equal '*Git'
    # expected result: <strong>*Git</strong>*Hub
  end
  it 'should parse a escaped single-line unconstrained emphasized chars' do
    # FIXME: Unexpected result, let's discuss it!
    skip 'Unexpected result. I would expect \__Git__Hub to be consistent with \**Git**Hub'
    ast = ::Asciidoctor::InlineParser.parse %(#{BACKSLASH}__Git__Hub)
    ast.text_value.must_equal %(#{BACKSLASH}__Git__Hub)
    nodes = find_by (node_type_must_be 'UnconstrainedEmphasis'), ast
    nodes.size.must_equal 0
    # QUESTION: Why the behavior is not consistent with the previous escaped unconstrained strong ?
  end
  it 'should parse a escaped single-line unconstrained emphasized chars around word' do
    # FIXME: Unexpected result, let's discuss it!
    skip 'Unexpected result. Im lost :|'
    ast = ::Asciidoctor::InlineParser.parse %(#{BACKSLASH}#{BACKSLASH}__GitHub__)
    ast.text_value.must_equal %(#{BACKSLASH}#{BACKSLASH}__GitHub__)
    nodes = find_by (node_type_must_be 'UnconstrainedEmphasis'), ast
    nodes.size.must_equal 0
  end
  it 'should parse a multi-line unconstrained emphasized chars' do
    ast = ::Asciidoctor::InlineParser.parse "__G\ni\nt\n__Hub"
    ast.text_value.must_equal "__G\ni\nt\n__Hub"
    nodes = find_by (node_type_must_be 'UnconstrainedEmphasis'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal "__G\ni\nt\n__"
    nodes.first.content.must_equal "G\ni\nt\n"
  end
  it 'should parse a unconstrained emphasis chars with role' do
    # FIXME: unconstrained emphasis chars with role are not yet supported
    skip 'unconstrained emphasis chars with role are not yet supported'
    ast = ::Asciidoctor::InlineParser.parse '[gray]__Git__Hub'
    ast.text_value.must_equal '[gray]__Git__Hub'
    # expected result: %q{<em class="gray">Git</em>Hub}
  end
  it 'should parse a escaped unconstrained emphasis chars with role' do
    # FIXME: eescaped unconstrained emphasis chars with role are not yet supported
    skip 'escaped unconstrained emphasis chars with role are not yet supported'
    ast = ::Asciidoctor::InlineParser.parse %(#{BACKSLASH}[gray]__Git__Hub)
    ast.text_value.must_equal %(#{BACKSLASH}[gray]__Git__Hub)
    # expected result: %q{[gray]__Git__Hub}
  end
  it 'should parse a single strong string in a sentence' do
    ast = ::Asciidoctor::InlineParser.parse('This is a *bold* statement.')
    ast.text_value.must_equal 'This is a *bold* statement.'
    nodes = find_by (node_type_must_be 'Strong'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '*bold*'
    nodes.first.content.must_equal 'bold'
  end
  it 'should parse a single strong string' do
    ast = ::Asciidoctor::InlineParser.parse('*bold*')
    ast.text_value.must_equal '*bold*'
    nodes = find_by (node_type_must_be 'Strong'), ast
    nodes.size.must_equal 1
    nodes.first.text_value.must_equal '*bold*'
    nodes.first.content.must_equal 'bold'
  end
  it 'should parse a single-line constrained marked string' do
    ast = ::Asciidoctor::InlineParser.parse('#Mark my words#')
    ast.text_value.must_equal '#Mark my words#'
    mark_nodes = find_by (node_type_must_be 'Mark'), ast
    mark_nodes.size.must_equal 1
    mark_nodes.first.text_value.must_equal '#Mark my words#'
  end
  it 'should parse a constrained monospaced code snippet' do
    ast = ::Asciidoctor::InlineParser.parse('`var i = \'abcd\';`')
    ast.text_value.must_equal '`var i = \'abcd\';`'
    monospaced_nodes = find_by (node_type_must_be 'Monospaced'), ast
    monospaced_nodes.size.must_equal 1
    monospaced_nodes.first.text_value.must_equal '`var i = \'abcd\';`'
  end
  it 'should parse a constrained superscript single letter' do
    ast = ::Asciidoctor::InlineParser.parse('E = mc^2^')
    ast.text_value.must_equal 'E = mc^2^'
    superscript_nodes = find_by (node_type_must_be 'Superscript'), ast
    superscript_nodes.size.must_equal 1
    superscript_nodes.first.text_value.must_equal '^2^'
  end
  it 'should parse a constrained subscript single letter' do
    ast = ::Asciidoctor::InlineParser.parse('~a~')
    ast.text_value.must_equal '~a~'
    subscript_nodes = find_by (node_type_must_be 'Subscript'), ast
    subscript_nodes.size.must_equal 1
    subscript_nodes.first.text_value.must_equal '~a~'
  end
  it 'should parse a constrained monospaced string that contains /* and */' do
    ast = ::Asciidoctor::InlineParser.parse('Use `/*` and `*/` for multiline comments.')
    ast.text_value.must_equal 'Use `/*` and `*/` for multiline comments.'
    monospaced_nodes = find_by (node_type_must_be 'Monospaced'), ast
    monospaced_nodes.size.must_equal 2
    monospaced_nodes[0].text_value.must_equal '`/*`'
    monospaced_nodes[1].text_value.must_equal '`*/`'
  end
  it 'should parse a nested quoted string (emphasis text inside a bold text)' do
    ast = ::Asciidoctor::InlineParser.parse('The next *few words are _really_ important!*')
    ast.text_value.must_equal 'The next *few words are _really_ important!*'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 1
    strong_nodes.first.text_value.must_equal '*few words are _really_ important!*'
    emphasis_nodes = find_by (node_type_must_be 'Emphasis'), ast
    emphasis_nodes.size.must_equal 1
  end
  it 'should parse a constrained emphasis string that contains numbers and the percent symbol' do
    ast = ::Asciidoctor::InlineParser.parse('The parser is working _99%_ of the time')
    ast.text_value.must_equal 'The parser is working _99%_ of the time'
    emphasis_nodes = find_by (node_type_must_be 'Emphasis'), ast
    emphasis_nodes.size.must_equal 1
    emphasis_nodes.first.text_value.must_equal '_99%_'
    emphasis_nodes.first.content.must_equal '99%'
  end
  it 'should parse a constrained emphasis string in a sentence' do
    ast = ::Asciidoctor::InlineParser.parse('few words are _really_ important!')
    ast.text_value.must_equal 'few words are _really_ important!'
    emphasis_nodes = find_by (node_type_must_be 'Emphasis'), ast
    emphasis_nodes.size.must_equal 1
    emphasis_nodes.first.text_value.must_equal '_really_'
  end
  it 'should parse a constrained strong string that contains an underscore symbol' do
    ast = ::Asciidoctor::InlineParser.parse('*_id* word_')
    ast.text_value.must_equal '*_id* word_'
    emphasis_nodes = find_by (node_type_must_be 'Emphasis'), ast
    emphasis_nodes.size.must_equal 0
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 1
    strong_nodes.first.content.must_equal '_id'
  end
  it 'should parse an escaped constrained strong string' do
    ast = ::Asciidoctor::InlineParser.parse('Escaped star symbol will not produce \*bold*.')
    ast.text_value.must_equal 'Escaped star symbol will not produce \*bold*.'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 0
  end
  it 'should parse a deep nested quoted string' do
    ast = ::Asciidoctor::InlineParser.parse('*Deep _nested `#quoted#` ^text^_*')
    ast.text_value.must_equal '*Deep _nested `#quoted#` ^text^_*'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 1
    strong_nodes.first.content.must_equal 'Deep _nested `#quoted#` ^text^_'
    emphasis_nodes = find_by (node_type_must_be 'Emphasis'), ast
    emphasis_nodes.size.must_equal 1
    emphasis_nodes.first.content.must_equal 'nested `#quoted#` ^text^'
    monospaced_nodes = find_by (node_type_must_be 'Monospaced'), ast
    monospaced_nodes.size.must_equal 1
    monospaced_nodes.first.content.must_equal '#quoted#'
    mark_nodes = find_by (node_type_must_be 'Mark'), ast
    mark_nodes.size.must_equal 1
    mark_nodes.first.content.must_equal 'quoted'
    superscript_nodes = find_by (node_type_must_be 'Superscript'), ast
    superscript_nodes.size.must_equal 1
    superscript_nodes.first.content.must_equal 'text'
  end
  it 'should parse a constrained strong string around a single letter' do
    ast = ::Asciidoctor::InlineParser.parse('I should use a unconstrained qu*o*te.')
    ast.text_value.must_equal 'I should use a unconstrained qu*o*te.'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 0
  end
  it 'should parse a constrained strong string with inner spaces' do
    ast = ::Asciidoctor::InlineParser.parse('I * should * use unconstrained quote.')
    ast.text_value.must_equal 'I * should * use unconstrained quote.'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 0
  end
  it 'should parse a constrained strong string with a trailing number' do
    ast = ::Asciidoctor::InlineParser.parse('*mc*2')
    ast.text_value.must_equal '*mc*2'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 0
  end
  it 'should parse a constrained strong string with a trailing colon' do
    ast = ::Asciidoctor::InlineParser.parse('I should use:*unconstrained* quote.')
    ast.text_value.must_equal 'I should use:*unconstrained* quote.'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 0
  end
  it 'should parse a constrained strong string with a trailing semi-colon' do
    ast = ::Asciidoctor::InlineParser.parse('I should use;*unconstrained* quote.')
    ast.text_value.must_equal 'I should use;*unconstrained* quote.'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 0
  end
  it 'should parse a constrained strong string with a trailing curly brace' do
    ast = ::Asciidoctor::InlineParser.parse('I should use}*unconstrained* quote.')
    ast.text_value.must_equal 'I should use}*unconstrained* quote.'
    strong_nodes = find_by (node_type_must_be 'Strong'), ast
    strong_nodes.size.must_equal 0
  end
end
