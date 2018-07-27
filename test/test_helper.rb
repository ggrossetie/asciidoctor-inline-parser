require 'simplecov'
SimpleCov.start

require 'minitest/autorun'


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
