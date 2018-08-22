require './lib/asciidoctor/inline_parser/subs'

module AsciidoctorGrammar
  # Text
  class Text < ::Treetop::Runtime::SyntaxNode
    def to_html
      @comprehensive_elements.first.to_html
    end
  end

  class Sentence < ::Treetop::Runtime::SyntaxNode
  end

  # Expression
  class Expression < ::Treetop::Runtime::SyntaxNode
    attr_reader :document

    def initialize input, interval, elements
      @document = ::Asciidoctor::Document.new # FIXME: use the current Asciidoctor Document
      super input, interval, elements
    end

    def to_html
      text = text_value
      if @comprehensive_elements.empty?
        apply_sub text
      else
        @comprehensive_elements.reverse_each do |el|
          text[el.interval] = el.to_html unless el.instance_of? ::Treetop::Runtime::SyntaxNode
        end
        text
      end
    end

    private

    def apply_sub text
      # TODO: Implement all the substitutions
      text = ::Asciidoctor::Subs.sub_specialchars text
      text = ::Asciidoctor::Subs.sub_attributes text, @document
      ::Asciidoctor::Subs.sub_replacements text
    end
  end

  # Quoted content
  class QuotedContent < ::Treetop::Runtime::SyntaxNode
    def to_html
      text_value
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
    def to_html
      "<strong>#{@comprehensive_elements.first.to_html}</strong>"
    end
  end

  # Emphasis
  class EmphasisQuoted < ::AsciidoctorGrammar::QuotedNode
    def to_html
      "<em>#{@comprehensive_elements.first.to_html}</em>"
    end
  end

  # Monospaced
  class MonospacedQuoted < ::AsciidoctorGrammar::QuotedNode
    def to_html
      "<code>#{@comprehensive_elements.first.to_html}</code>"
    end
  end

  # Double curved
  class DoubleCurvedQuoted < ::AsciidoctorGrammar::QuotedNode
    def to_html
      "“#{@comprehensive_elements.first.to_html}”"
    end
  end

  # Single curved
  class SingleCurvedQuoted < ::AsciidoctorGrammar::QuotedNode
    def to_html
      "‘#{@comprehensive_elements.first.to_html}’"
    end
  end

  # Literal
  class Literal < ::Treetop::Runtime::SyntaxNode
    def to_html
      @comprehensive_elements.first.text_value
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

    def to_html
      %(<a href="#{target}" class="#{roles.join(',')}"#{window ? %( target="#{window}") : ''}>#{text}</a>)
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
      return ['bare'] if attrs_node.nil? || attrs_node.roles.empty?
      attrs_node.roles
    end
  end

  # Link scheme
  class LinkScheme < ::Treetop::Runtime::SyntaxNode
    def to_html
      text_value
    end
  end

  # Link path
  class LinkPath < ::Treetop::Runtime::SyntaxNode
    def to_html
      text_value
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
    def to_html
      %(<a href="mailto:#{email_address}">#{email_address}</a>)
    end

    def email_address
      email_node = @comprehensive_elements.select { |el| email? el }.first
      email_node.text_value if email_node
    end

    private

    def email? node
      node.instance_of? ::AsciidoctorEmailGrammar::Email
    end
  end
  # Email
  class Email < ::Treetop::Runtime::SyntaxNode
    def to_html
      %(<a href="mailto:#{email_address}">#{email_address}</a>)
    end

    def email_address
      text_value
    end
  end
  class EmailAttributes < ::Treetop::Runtime::SyntaxNode
  end
  class EmailAttributesContent < ::Treetop::Runtime::SyntaxNode
  end
  # Escaped email
  class EscapedEmail < ::Treetop::Runtime::SyntaxNode
    def to_html
      text = text_value
      text[0] = ''
      text
    end
  end
end

module AsciidoctorPassthroughGrammar
  # Escaped passthrough inline macro
  class EscapedPassthroughInlineMacro < ::Treetop::Runtime::SyntaxNode
    def to_html
      text_value.gsub '\pass:', 'pass:'
    end
  end

  # Passthrough inline macro
  class PassthroughInlineMacro < ::Treetop::Runtime::SyntaxNode
    def to_html
      text = content
      apply_subs text
    end

    def content
      content_node = @comprehensive_elements.select { |el| passthrough_inline_macro_content? el }.first
      content_node.text_value if content_node
    end

    def subs
      subs_node = @comprehensive_elements.select { |el| passthrough_inline_macro_subs? el }.first
      subs_node.subs if subs_node
    end

    private

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
    def to_html
      content
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
