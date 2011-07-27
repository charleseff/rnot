require 'rspec/core/rake_task'

desc 'Default: run spec tests.'
task :default => :spec

namespace :spec do
  desc "Run unit specs"
    RSpec::Core::RakeTask.new('unit') do |t|
#    t.rspec_opts = ['--options', "spec/spec.opts"]
    t.pattern = FileList['spec/**/*_spec.rb']
  end
end

desc "Run the unit and acceptance specs"
task :spec => ['spec:unit']
