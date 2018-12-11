module Asciidoctor
  module InlineParser
    # Inline node
    class Node
      # The unparsed text that may contain formatting marks and inline elements
      attr_accessor :source

      # The parsed text attached to the current node
      attr_accessor :text

      # Node parent
      attr_accessor :parent

      # Children nodes
      attr_accessor :children

      def initialize
        @children = []
      end
    end

    class Strong < Node
    end

    class Emphasis < Node
    end

    class Mark < Node
    end

    class Code < Node
    end

    class Superscript < Node
    end

    class Subscript < Node
    end

    # Anchor
    class Anchor < Node
      # The anchor URI (target)
      attr_accessor :target

      # The name of the anchor
      # QUESTION should we rename to "name" or "label" ?
      # QUESTION if the name is not defined, should the value be nil or equals to the target ?
      attr_accessor :link

      # An array of roles
      attr_accessor :roles
    end

    # Email
    class Email < Node
      # The email address (target)
      attr_accessor :target

      # The name of the link
      # QUESTION should we rename to "name" or "label" ?
      # QUESTION if the name is not defined, should the value be nil or equals to the target ?
      attr_accessor :link

      # The subject of the email (may be nil)
      attr_accessor :subject

      # The body of the email (may be nil)
      attr_accessor :body
    end

    class DoubleQuotation < Node
    end

    class SingleQuotation < Node
    end

    # Text node
    class Text < Node
    end

    class Image
    end

    class Keyboard
    end

    class Button
    end
  end
end
