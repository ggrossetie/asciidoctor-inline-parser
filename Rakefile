require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*_test.rb']
end
desc 'Run tests'

RuboCop::RakeTask.new(:rubocop) do |task|
  task.options << '--fail-fast'
end
desc 'Run RuboCop'

task default: [:rubocop, :test]
