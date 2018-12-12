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

      alias address target
    end

    class DoubleQuotation < Node
    end

    class SingleQuotation < Node
    end

    # Text node
    class Text < Node
    end

    # Image
    class Image < Node
      # QUESTION what the text of this node should be ? the alt ? the target ?

      # The textual description of the image (may be nil)
      attr_accessor :alt

      # The title of the image (may be nil)
      attr_accessor :title

      # The image URL (src)
      attr_accessor :target

      # The image width (may be nil)
      attr_accessor :width

      # The image height (may be nil)
      attr_accessor :height

      # An array of roles
      # QUESTION should we move roles up in the class hierarchy ?
      attr_accessor :roles
    end

    # Keyboard kbd
    class Keyboard < Node
      # The list of keys combination
      attr_accessor :keys
    end

    class Button
    end

    # Passthrough
    class Pass < Node
      # The list of substitutions to apply
      attr_accessor :substitutions

      def initialize
        @substitutions = []
      end
    end
  end
end
