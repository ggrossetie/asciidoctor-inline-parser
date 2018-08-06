module AsciidoctorGrammar
  class Text < ::Treetop::Runtime::SyntaxNode
  end

  class Sentence < ::Treetop::Runtime::SyntaxNode
  end

  class Expression < ::Treetop::Runtime::SyntaxNode
  end

  class QuotedContent < ::Treetop::Runtime::SyntaxNode
  end

  # Quoted node
  class QuotedNode < ::Treetop::Runtime::SyntaxNode
    def content
      @elements.select { |el| el.instance_of? ::AsciidoctorGrammar::QuotedContent }.first.text_value
    end
  end

  class StrongQuoted < ::AsciidoctorGrammar::QuotedNode
  end

  class EmphasisQuoted < ::AsciidoctorGrammar::QuotedNode
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
