# rubocop:disable Metrics/ClassLength
class Html5Converter
  attr_reader :document

  def initialize
    @document = ::Asciidoctor::Document.new # FIXME: use the current Asciidoctor Document
  end

  def text node
    convert node.elements.first
  end

  def strong node
    "<strong>#{convert node.elements.first}</strong>"
  end

  def emphasis node
    "<em>#{convert node.elements.first}</em>"
  end

  def monospaced node
    "<code>#{convert node.elements.first}</code>"
  end

  def inline node
    text = node.text_value
    elements = node.instance_variable_get('@comprehensive_elements')
    if elements.nil?
      convert node # workaround for LiteralLine
    elsif elements.empty?
      apply_sub text
    else
      elements.reverse_each do |el|
        text[el.interval] = convert el unless el.instance_of? ::Treetop::Runtime::SyntaxNode
      end
      text
    end
  end

  def double_quotation node
    "“#{convert node.elements.first}”"
  end

  def single_quotation node
    "‘#{convert node.elements.first}’"
  end

  def literal node
    node.elements.first.text_value
  end

  def literal_line node
    %(<div class="literalblock">
<div class="content">
<pre>#{node.text}</pre>
</div>
</div>)
  end

  def anchor node
    roles_html = !node.roles.empty? ? %( class="#{node.roles.join(',')}") : ''
    %(<a href="#{node.target}"#{roles_html}#{node.window ? %( target="#{node.window}") : ''}>#{node.text}</a>)
  end

  def link_scheme node
    node.text_value
  end

  def link_path node
    node.text_value
  end

  def email_macro node
    subject_text = %(?subject=#{uri_encode_spaces node.subject}) if node.subject
    body_text = %(&amp;body=#{uri_encode_spaces node.body}) if node.body
    link = %(#{node.email}#{subject_text}#{body_text})
    %(<a href="mailto:#{link}">#{node.name}</a>)
  end

  def email node
    %(<a href="mailto:#{node.email}">#{node.text}</a>)
  end

  def escaped_email node
    text = node.text_value
    text[0] = ''
    text
  end

  def passthrough node
    node.text_value.gsub '\pass:', 'pass:'
  end

  def passthrough_inline node
    text = node.content
    node.apply_subs text
  end

  def passthrough_triple_plus node
    node.content
  end

  def image node
    width_html = node.width ? %( width="#{node.width}") : ''
    height_html = node.height ? %( height="#{node.height}") : ''
    class_html = node.roles.empty? ? '' : %(class="#{node.roles.join(' ')}")
    alt_html = node.alt ? %( alt="#{node.alt}") : ''
    title_html = node.title ? %( title="#{node.title}") : ''
    %(<span #{class_html}><img src="#{node.target}"#{alt_html}#{title_html}#{width_html}#{height_html}></span>)
  end

  def kbd node
    keys_html = lambda { |el|
      el.keys.map { |key| "<kbd>#{(key.empty? ? '+' : key).strip.gsub '\]', ']'}</kbd>" }.join '+'
    }
    if node.keys.size > 1
      %(<span class="keyseq">#{keys_html.call node}</span>)
    else
      keys_html.call node
    end
  end

  def btn node
    %(<b class="button">#{node.text}</b>)
  end

  # rubocop:disable Metrics/AbcSize
  def menu node
    item_class = lambda { |index, size|
      if index.zero?
        'menu'
      elsif index == size - 1
        'menuitem'
      else
        'submenu'
      end
    }
    items = node.items
    items_html = items.each_with_index.map do |item, index|
      item_text = item.strip.gsub '\]', ']'
      %(<b class="#{item_class.call index, items.size}">#{item_text}</b>)
    end.join '&nbsp;<i class="fa fa-angle-right caret"></i> '
    if items && items.size > 1
      %(<span class="menuseq">#{items_html}</span>)
    else
      %(<b class="menuref">#{items[0].strip.gsub '\]', ']'}</b>)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def convert node
    transform = node.node_name
    (send transform, node)
  end

  private

  def apply_sub text
    # TODO: Implement all the substitutions
    text = ::Asciidoctor::Subs.sub_specialchars text
    text = ::Asciidoctor::Subs.sub_attributes text, @document
    ::Asciidoctor::Subs.sub_replacements text
  end

  SPACE = ' '.freeze

  def uri_encode_spaces str
    if str.include? SPACE
      str.gsub SPACE, '%20'
    else
      str
    end
  end
end
# rubocop:enable Metrics/ClassLength
