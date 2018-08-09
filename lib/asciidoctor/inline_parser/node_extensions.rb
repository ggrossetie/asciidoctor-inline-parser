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
  end

  # Strong quoted
  class StrongQuoted < ::AsciidoctorGrammar::QuotedNode
    def to_html
      "<strong>#{@comprehensive_elements.first.to_html}</strong>"
    end
  end

  # Emphasis quoted
  class EmphasisQuoted < ::AsciidoctorGrammar::QuotedNode
    def to_html
      "<em>#{@comprehensive_elements.first.to_html}</em>"
    end
  end

  class MonospacedQuoted < ::AsciidoctorGrammar::QuotedNode
  end

  class MarkQuoted < ::AsciidoctorGrammar::QuotedNode
  end

  class SuperscriptQuoted < ::AsciidoctorGrammar::QuotedNode
  end

  class SubscriptQuoted < ::AsciidoctorGrammar::QuotedNode
  end
end
