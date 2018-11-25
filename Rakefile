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
  treetop_grammar_files = File.join(path, '**', '*.treetop')
  Dir.glob(treetop_grammar_files).each do |treetop_grammar_file|
    target_file = "#{File.basename(treetop_grammar_file, '.treetop')}.rb"
    target = File.join(File.dirname(treetop_grammar_file), target_file)
    compiler.compile(treetop_grammar_file, target)
  end
  compiler.compile("#{path}/asciidoctor_grammar.treetop", "#{path}/asciidoctor_grammar.rb")
end
desc 'Compile .treetop files to Ruby'
task default: [:compile, :rubocop, :test]
