module AsciidoctorGrammar
  class Text < Treetop::Runtime::SyntaxNode
  end

  class Sentence < Treetop::Runtime::SyntaxNode
  end

  class Expression < Treetop::Runtime::SyntaxNode
  end

  # Strong node
  class StrongQuoted < Treetop::Runtime::SyntaxNode
    def content
      @elements[1].text_value
    end
  end

  # Emphasis node
  class EmphasisQuoted < Treetop::Runtime::SyntaxNode
    def content
      @elements[1].text_value
    end
  end

  class MonospacedQuoted < Treetop::Runtime::SyntaxNode
  end

  class MarkQuoted < Treetop::Runtime::SyntaxNode
  end

  class SuperscriptQuoted < Treetop::Runtime::SyntaxNode
  end

  class SubscriptQuoted < Treetop::Runtime::SyntaxNode
  end
end
