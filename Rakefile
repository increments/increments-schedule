require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new do |task|
  task.verbose = false
end

RuboCop::RakeTask.new

desc 'Generate README.md from README.md.erb'
task :readme do
  puts 'Generating README.md...'
  File.write('README.md', generate_readme)
  puts 'Done.'
end

namespace :readme do
  task :validate do
    puts 'Validating README.md...'

    unless File.read('README.md') == generate_readme
      raise <<-END.gsub(/^\s+\|/, '').chomp
        |README.md and README.md.erb are out of sync!
        |If you need to modify the content of README.md:
        |  * Edit README.md.erb.
        |  * Run `bundle exec rake readme`.
        |  * Commit both files.
      END
    end

    puts 'Done.'
  end
end

def generate_readme
  require 'erb'
  require 'increments/schedule'
  readme = File.read('README.md.erb')
  erb = ERB.new(readme, nil, '-')
  erb.result(binding)
end

ci_tasks = %w(spec rubocop)
# For some reason MRI 2.3 returns the method list with different order.
ci_tasks << 'readme:validate' if RUBY_VERSION.start_with?('2.2.')
task ci: ci_tasks
