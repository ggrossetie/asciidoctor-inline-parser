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
    def to_html
      raw_text = text_value
      return text_value if @comprehensive_elements.empty?
      @comprehensive_elements.reverse_each do |el|
        raw_text[el.interval] = el.to_html unless el.instance_of? ::Treetop::Runtime::SyntaxNode
      end
      raw_text
    end
  end

  # Quoted content
  class QuotedContent < ::Treetop::Runtime::SyntaxNode
    def to_html
      @comprehensive_elements.first.to_html
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

  class RoleIdentifier < ::Treetop::Runtime::SyntaxNode
  end

  class AnchorIdentifier < ::Treetop::Runtime::SyntaxNode
  end

  class SuperscriptQuoted < ::AsciidoctorGrammar::QuotedNode
  end

  class SubscriptQuoted < ::AsciidoctorGrammar::QuotedNode
  end
end
