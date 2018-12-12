require_relative 'subs'

module AsciidoctorGrammar
  # Text
  class Text < ::Treetop::Runtime::SyntaxNode
    def node_name
      'text'
    end
  end

  class Sentence < ::Treetop::Runtime::SyntaxNode
  end

  # Expression
  class Expression < ::Treetop::Runtime::SyntaxNode
    def node_name
      'inline'
    end
  end

  # Quoted content
  class QuotedContent < ::Treetop::Runtime::SyntaxNode
    def node_name
      'formatted'
    end
  end

  # Quoted node
  class QuotedNode < ::Treetop::Runtime::SyntaxNode
    def content
      @elements.select { |el| el.instance_of? ::AsciidoctorGrammar::QuotedContent }.first.text_value
    end

    def nested?
      @elements.any? { |el| el.class.ancestors.include? ::AsciidoctorGrammar::QuotedNode }
    end

    def roles
      attributes_node = @elements.select { |el| el.instance_of? ::AsciidoctorGrammar::QuotedTextAttributes }.first
      attributes_node.roles if attributes_node
    end

    def id
      attributes_node = @elements.select { |el| el.instance_of? ::AsciidoctorGrammar::QuotedTextAttributes }.first
      attributes_node.id if attributes_node
    end
  end

  # Strong
  class StrongQuoted < ::AsciidoctorGrammar::QuotedNode
    def node_name
      'strong'
    end
  end

  # Emphasis
  class EmphasisQuoted < ::AsciidoctorGrammar::QuotedNode
    def node_name
      'emphasis'
    end
  end

  # Monospaced
  class MonospacedQuoted < ::AsciidoctorGrammar::QuotedNode
    def node_name
      'monospaced'
    end
  end

  # Double curved
  class DoubleCurvedQuoted < ::AsciidoctorGrammar::QuotedNode
    def node_name
      'double_quotation'
    end
  end

  # Single curved
  class SingleCurvedQuoted < ::AsciidoctorGrammar::QuotedNode
    def node_name
      'single_quotation'
    end
  end

  # Literal
  class Literal < ::Treetop::Runtime::SyntaxNode
    def node_name
      'literal'
    end
  end

  # Literal (single) line
  class LiteralLine < ::Treetop::Runtime::SyntaxNode
    def node_name
      'literal_line'
    end

    def text
      input
    end
  end

  # Mark
  class MarkQuoted < ::AsciidoctorGrammar::QuotedNode
  end

  # Quoted text anchor (id)
  class QuotedTextRole < ::AsciidoctorGrammar::QuotedNode
    def name
      role_node = @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::RoleIdentifier }.first
      role_node.text_value if role_node
    end
  end

  # Quoted text role
  class QuotedTextAnchor < ::AsciidoctorGrammar::QuotedNode
    def name
      anchor_node = @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::AnchorIdentifier }.first
      anchor_node.text_value if anchor_node
    end
  end

  # Quoted text attributes: anchor and roles
  class QuotedTextAttributes < ::Treetop::Runtime::SyntaxNode
    def roles
      content_node = @comprehensive_elements.select do |el|
        el.instance_of? ::AsciidoctorGrammar::QuotedTextAttributesContent
      end.first
      content_node.roles if content_node
    end

    def id
      content_node = @comprehensive_elements.select do |el|
        el.instance_of? ::AsciidoctorGrammar::QuotedTextAttributesContent
      end.first
      content_node.id if content_node
    end
  end

  # Quoted text attributes content: anchor and roles
  class QuotedTextAttributesContent < ::Treetop::Runtime::SyntaxNode
    def roles
      @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::QuotedTextRole }.map(&:name).compact
    end

    def id
      anchor_node = @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::QuotedTextAnchor }.first
      anchor_node.name if anchor_node
    end
  end

  class MacroAttributes < ::Treetop::Runtime::SyntaxNode
  end

  class RoleIdentifier < ::Treetop::Runtime::SyntaxNode
  end

  class AnchorIdentifier < ::Treetop::Runtime::SyntaxNode
  end

  class SuperscriptQuoted < ::AsciidoctorGrammar::QuotedNode
  end

  class SubscriptQuoted < ::AsciidoctorGrammar::QuotedNode
  end
end

module AsciidoctorLinkGrammar
  # Link
  class Link < ::Treetop::Runtime::SyntaxNode
    BLANK_SHORTHAND = '^'.freeze

    def node_name
      'anchor'
    end

    def target
      scheme + path
    end

    def scheme
      scheme_node = @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::LinkScheme }.first
      scheme_node.text_value if scheme_node
    end

    def path
      path_node = @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::LinkPath }.first
      path_node.text_value if path_node
    end

    def text
      attrs_node = @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::LinkAttributes }.first
      if attrs_node
        text = attrs_node.text
        return text.chop if text.end_with? BLANK_SHORTHAND
        return text
      end
      target
    end

    def window
      attrs_node = @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::LinkAttributes }.first
      return '_blank' if attrs_node && (attrs_node.text.end_with? BLANK_SHORTHAND)
      attrs_node.window if attrs_node && attrs_node.window
    end

    def roles
      attrs_node = @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::LinkAttributes }.first
      return ['bare'] if attrs_node.nil? || (attrs_node.roles.empty? && attrs_node.text.nil?)
      attrs_node.roles
    end
  end

  # Link scheme
  class LinkScheme < ::Treetop::Runtime::SyntaxNode
    def node_name
      'link_scheme'
    end
  end

  # Link path
  class LinkPath < ::Treetop::Runtime::SyntaxNode
    def node_name
      'link_path'
    end
  end

  # Link attributes (content)
  class LinkAttributesContent < ::Treetop::Runtime::SyntaxNode
    def roles
      @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::LinkRole }.map(&:name).compact
    end

    def text
      text_node = @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::LinkText }.first
      return text_node.name if text_node
      protected_text_node = @comprehensive_elements.select do |el|
        el.instance_of? ::AsciidoctorGrammar::LinkTextProtected
      end.first
      protected_text_node.name if protected_text_node
    end

    def window
      window_node = @comprehensive_elements.select { |el| el.instance_of? ::AsciidoctorGrammar::LinkWindow }.first
      window_node.name if window_node
    end
  end

  # Link attributes
  class LinkAttributes < ::Treetop::Runtime::SyntaxNode
    def text
      attrs_node = @comprehensive_elements.select { |el| link_attributes_content? el }.first
      attrs_node.text if attrs_node
    end

    def roles
      attrs_node = @comprehensive_elements.select { |el| link_attributes_content? el }.first
      attrs_node.roles if attrs_node
    end

    def window
      attrs_node = @comprehensive_elements.select { |el| link_attributes_content? el }.first
      attrs_node.window if attrs_node
    end

    private

    def link_attributes_content? node
      node.instance_of? ::AsciidoctorGrammar::LinkAttributesContent
    end
  end

  # Link role
  class LinkRole < ::Treetop::Runtime::SyntaxNode
    def name
      @elements[1].text_value # [0]: role=" [1]: name
    end
  end

  # Link window
  class LinkWindow < ::Treetop::Runtime::SyntaxNode
    def name
      @elements[1].text_value # [0]: window=" [1]: name
    end
  end

  # Link text
  class LinkText < ::Treetop::Runtime::SyntaxNode
    def name
      text_value
    end
  end

  # Link text protected with double quotes
  class LinkTextProtected < ::Treetop::Runtime::SyntaxNode
    def name
      @elements[1].text_value # [0]: " [1]: name
    end
  end
end

module AsciidoctorEmailGrammar
  # Email macro
  class EmailMacro < ::Treetop::Runtime::SyntaxNode
    def node_name
      'email_macro'
    end

    def name
      attrs_node = @comprehensive_elements.select { |el| email_attrs? el }.first
      return attrs_node.name if attrs_node && attrs_node.name
      email
    end

    def subject
      attrs_node = @comprehensive_elements.select { |el| email_attrs? el }.first
      attrs_node.subject if attrs_node
    end

    def body
      attrs_node = @comprehensive_elements.select { |el| email_attrs? el }.first
      attrs_node.body if attrs_node
    end

    def email
      email_node = @comprehensive_elements.select { |el| email? el }.first
      email_node.email if email_node
    end

    def email? node
      node.instance_of? ::AsciidoctorEmailGrammar::Email
    end

    def email_attrs? node
      node.instance_of? ::AsciidoctorEmailGrammar::EmailAttributes
    end
  end
  # Email
  class Email < ::Treetop::Runtime::SyntaxNode
    def node_name
      'email'
    end

    def text
      email
    end

    def email
      text_value
    end
  end
  # Email attributes
  class EmailAttributes < ::Treetop::Runtime::SyntaxNode
    def name
      attrs_node = @comprehensive_elements.select { |el| email_attrs_content? el }.first
      attrs_node.name if attrs_node
    end

    def subject
      attrs_node = @comprehensive_elements.select { |el| email_attrs_content? el }.first
      attrs_node.subject if attrs_node
    end

    def body
      attrs_node = @comprehensive_elements.select { |el| email_attrs_content? el }.first
      attrs_node.body if attrs_node
    end

    private

    def email_attrs_content? node
      node.instance_of? ::AsciidoctorEmailGrammar::EmailAttributesContent
    end
  end
  # Email attributes content
  class EmailAttributesContent < ::Treetop::Runtime::SyntaxNode
    def name
      attrs.first.text_value if attrs && !attrs.empty?
    end

    def subject
      attrs[1].text_value if attrs && attrs.length > 1
    end

    def body
      attrs[2].text_value if attrs && attrs.length > 2
    end

    def attrs
      @comprehensive_elements.select { |el| email_text? el }
    end

    private

    def email_text? node
      node.instance_of? ::AsciidoctorEmailGrammar::EmailText
    end
  end
  class EmailTextProtected < ::Treetop::Runtime::SyntaxNode
  end
  class EmailText < ::Treetop::Runtime::SyntaxNode
  end
  # Escaped email
  class EscapedEmail < ::Treetop::Runtime::SyntaxNode
    def node_name
      'escaped_email'
    end
  end
end

module AsciidoctorPassthroughGrammar
  # Escaped passthrough inline macro
  class EscapedPassthroughInlineMacro < ::Treetop::Runtime::SyntaxNode
    def node_name
      'passthrough'
    end
  end

  # Passthrough inline macro
  class PassthroughInlineMacro < ::Treetop::Runtime::SyntaxNode
    def node_name
      'passthrough_inline'
    end

    def content
      content_node = @comprehensive_elements.select { |el| passthrough_inline_macro_content? el }.first
      content_node.text_value if content_node
    end

    def subs
      subs_node = @comprehensive_elements.select { |el| passthrough_inline_macro_subs? el }.first
      subs_node.subs if subs_node
    end

    def apply_subs text
      # TODO: Implement all the substitutions
      text = text.gsub '\]', ']'
      if (subs.include? 'verbatim') || (subs.include? 'specialcharacters') || (subs.include? 'specialchars')
        text = ::Asciidoctor::Subs.sub_specialchars text
      end
      text
    end

    def passthrough_inline_macro_content? node
      node.instance_of? ::AsciidoctorGrammar::PassthroughInlineMacroContent
    end

    def passthrough_inline_macro_subs? node
      node.instance_of? ::AsciidoctorGrammar::PassthroughInlineMacroSubs
    end
  end
  # Passthrough inline macro subs
  class PassthroughInlineMacroSubs < ::Treetop::Runtime::SyntaxNode
    def subs
      @comprehensive_elements
        .select { |el| el.instance_of? ::AsciidoctorGrammar::PassthroughInlineMacroSub }
        .map(&:text_value)
    end
  end
  class PassthroughInlineMacroSub < ::Treetop::Runtime::SyntaxNode
  end
  class PassthroughInlineMacroContent < ::Treetop::Runtime::SyntaxNode
  end
  # Passthrough using +++ (triple plus)
  class PassthroughTriplePlus < ::Treetop::Runtime::SyntaxNode
    def node_name
      'passthrough_triple_plus'
    end

    def content
      content_node = @comprehensive_elements.select { |el| passthrough_triple_plus_content? el }.first
      content_node.text_value if content_node
    end

    private

    def passthrough_triple_plus_content? node
      node.instance_of? ::AsciidoctorGrammar::PassthroughTriplePlusContent
    end
  end
  class PassthroughTriplePlusContent < ::Treetop::Runtime::SyntaxNode
  end
end

module AsciidoctorImageGrammar
  # Image
  class Image < ::Treetop::Runtime::SyntaxNode
    def node_name
      'image'
    end

    def roles
      get_attr 'roles'
    end

    def target
      target_node = @comprehensive_elements.select { |el| image_target? el }.first
      target_node.name if target_node
    end

    def alt
      value = get_attr 'alt'
      if value
        value
      else
        extname = File.extname(target)
        ::File.basename(target, extname)
      end
    end

    def title
      get_attr 'title'
    end

    def width
      get_attr 'width'
    end

    def height
      get_attr 'height'
    end

    private

    def get_attr name
      attrs_node = @comprehensive_elements.select { |el| image_attrs? el }.first
      attrs_node.public_send(name) if attrs_node && (attrs_node.respond_to? name)
    end

    def image_target? node
      node.instance_of? ::AsciidoctorImageGrammar::ImageTarget
    end

    def image_attrs? node
      node.instance_of? ::AsciidoctorImageGrammar::ImageAttributes
    end
  end
  # Attributes
  class ImageAttributes < ::Treetop::Runtime::SyntaxNode
    def title
      content_node = @comprehensive_elements.select { |el| attr_content? el }.first
      # named attribute 'title'
      content_node.attrs['title'] if content_node
    end

    def alt
      content_node = @comprehensive_elements.select { |el| attr_content? el }.first
      # named attribute 'alt' or the first attribute (0 based index)
      content_node.attrs['alt'] || content_node.attrs['0'] if content_node
    end

    def width
      content_node = @comprehensive_elements.select { |el| attr_content? el }.first
      # named attribute 'alt' or the second attribute (0 based index)
      content_node.attrs['width'] || content_node.attrs['1'] if content_node
    end

    def height
      content_node = @comprehensive_elements.select { |el| attr_content? el }.first
      # named attribute 'alt' or the third attribute (0 based index)
      content_node.attrs['height'] || content_node.attrs['2'] if content_node
    end

    def roles
      result = ['image']
      content_node = @comprehensive_elements.select { |el| attr_content? el }.first
      # named attribute 'alt' or the fourth attribute (0 based index)
      if content_node
        roles = content_node.attrs['role'] || content_node.attrs['3'] || ''
        result += roles.split(',').map { |role| role.strip! || role }
      end
      result
    end

    private

    def attr_content? node
      node.instance_of? ::AsciidoctorImageGrammar::ImageAttributesContent
    end
  end
  # Image target
  class ImageTarget < ::Treetop::Runtime::SyntaxNode
    def name
      text_value
    end
  end
  # Attributes content
  class ImageAttributesContent < ::Treetop::Runtime::SyntaxNode
    def attrs
      @comprehensive_elements.select { |el| (named_attr? el) || (attr_value? el) }
                             .each_with_index.map do |el, index|
                               if named_attr? el
                                 { el.key => el.value }
                               elsif attr_value? el
                                 { index.to_s => el.value }
                               end
                             end.inject(:merge)
    end

    private

    def named_attr? node
      node.instance_of? ::AsciidoctorImageGrammar::ImageNamedAttribute
    end

    def attr_value? node
      node.instance_of? ::AsciidoctorImageGrammar::ImageAttributeValue
    end
  end
  # Named attribute
  class ImageNamedAttribute < ::Treetop::Runtime::SyntaxNode
    def key
      key_node = @comprehensive_elements.select { |el| attr_key? el }.first
      key_node.text_value if key_node
    end

    def value
      value_node = @comprehensive_elements.select { |el| attr_value? el }.first
      value_node.value if value_node
    end

    private

    def attr_key? node
      node.instance_of? ::AsciidoctorImageGrammar::ImageNamedAttributeKey
    end

    def attr_value? node
      (attr_value_unprotected? node) || (attr_value_protected? node)
    end

    def attr_value_unprotected? node
      node.instance_of? ::AsciidoctorImageGrammar::ImageNamedAttributeValue
    end

    def attr_value_protected? node
      node.instance_of? ::AsciidoctorImageGrammar::ImageAttributeValueProtected
    end
  end
  class ImageNamedAttributeKey < ::Treetop::Runtime::SyntaxNode
  end
  # Named attribute value
  class ImageNamedAttributeValue < ::Treetop::Runtime::SyntaxNode
    def value
      @comprehensive_elements.first.value
    end
  end
  # Attribute value protected with double quotes
  class ImageAttributeValueProtected < ::Treetop::Runtime::SyntaxNode
    def value
      @elements[1].text_value # [0]: " [1]: name
    end
  end
  # Attribute value
  class ImageAttributeValue < ::Treetop::Runtime::SyntaxNode
    def value
      text_value
    end
  end
end

module AsciidoctorKbdGrammar
  # Keyboard kbd inline macro
  class Kbd < ::Treetop::Runtime::SyntaxNode
    def node_name
      'kbd'
    end

    def keys
      content_node = @comprehensive_elements.select { |el| attr_content? el }.first
      content_node.text_value
                  .split('+')
                  .map(&:strip)
                  .map { |key| key.empty? ? '+' : (key.strip.gsub '\]', ']') } if content_node
    end

    private

    def attr_content? node
      node.instance_of? ::AsciidoctorKbdGrammar::KbdContent
    end
  end
  class KbdContent < ::Treetop::Runtime::SyntaxNode
  end
end

module AsciidoctorBtnGrammar
  # Button btn inline macro
  class Btn < ::Treetop::Runtime::SyntaxNode
    def node_name
      'btn'
    end

    def text
      content_node = @comprehensive_elements.select { |el| attr_content? el }.first
      content_node.text_value if content_node
    end

    private

    def attr_content? node
      node.instance_of? ::AsciidoctorBtnGrammar::BtnContent
    end
  end
  class BtnContent < ::Treetop::Runtime::SyntaxNode
  end
end

module AsciidoctorMenuGrammar
  # Menu inline macro
  class Menu < ::Treetop::Runtime::SyntaxNode
    def node_name
      'menu'
    end

    def items
      result = []
      target_node = @comprehensive_elements.select { |el| target? el }.first
      result.push(target_node.text_value) if target_node
      content_node = @comprehensive_elements.select { |el| content? el }.first
      result.concat(content_node.text_value.split('>').map(&:strip)) if content_node
      result
    end

    private

    def content? node
      node.instance_of? ::AsciidoctorMenuGrammar::MenuContent
    end

    def target? node
      node.instance_of? ::AsciidoctorMenuGrammar::MenuTarget
    end
  end
  class MenuTarget < ::Treetop::Runtime::SyntaxNode
  end
  class MenuContent < ::Treetop::Runtime::SyntaxNode
  end
end
