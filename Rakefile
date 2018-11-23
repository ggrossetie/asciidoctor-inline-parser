require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'
require 'treetop'
require 'polyglot'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end
desc 'Run tests'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options << '--fail-fast'
end
desc 'Run RuboCop'

task :compile do
  compiler = Treetop::Compiler::GrammarCompiler.new
  path = 'lib/asciidoctor/inline_parser/'
  compiler.compile("#{path}/asciidoctor_grammar.treetop", "#{path}/asciidoctor_grammar.rb")
end
desc 'Compile .treetop file to Ruby'

task default: [:compile, :rubocop, :test]
