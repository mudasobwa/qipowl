require 'bundler/setup'

require 'rspec/core/rake_task'

desc 'Tests'
RSpec::Core::RakeTask.new(:spec) do |spec|
#  spec.rspec_opts = '-Ispec'
#  spec.rcov = true
end

require 'cucumber/rake/task'
desc 'Cucumber'
Cucumber::Rake::Task.new(:features)

task :default => :features

require 'yard'
desc 'YARD'
YARD::Rake::YardocTask.new(:yard)
