require 'simplecov'
SimpleCov.start

require 'minitest/autorun'

BACKSLASH = %(\x5c).freeze

private def debug ast
  if ast
    p ast
    p ast.parent
    p ast.input
    p ast.text_value
    p ast.terminal?
    p ast.interval
  else
    p 'No match'
  end
end

private def find_by condition, node, result = []
  result if node.nil?
  node.elements.each do |e|
    result << e if condition.call(e)
    find_by condition, e, result if e.elements && !e.elements.empty?
  end
  result
end

private def node_type_must_be name
  ->(node) { node.extension_modules.map(&:to_s).include? "AsciidoctorGrammar::#{name}0" }
end
