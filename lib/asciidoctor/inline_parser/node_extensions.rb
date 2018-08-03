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

    def role
      @elements.select { |el| el.instance_of? ::AsciidoctorGrammar::Role }.first.name
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
      "&#8220;#{@comprehensive_elements.first.to_html}&#8221;" # REMIND: Opal won't compile the unicode characters
    end
  end

  # Single curved
  class SingleCurvedQuoted < ::AsciidoctorGrammar::QuotedNode
    def to_html
      "&#8216;#{@comprehensive_elements.first.to_html}&#8217;" # REMIND: Opal won't compile the unicode characters
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

  # Role
  class Role < ::Treetop::Runtime::SyntaxNode
    def name
      @elements.select { |el| el.instance_of? ::AsciidoctorGrammar::RoleIdentifier }.first.text_value
    end
  end

  class RoleIdentifier < ::Treetop::Runtime::SyntaxNode
  end

  class SuperscriptQuoted < ::AsciidoctorGrammar::QuotedNode
  end

  class SubscriptQuoted < ::AsciidoctorGrammar::QuotedNode
  end
end
