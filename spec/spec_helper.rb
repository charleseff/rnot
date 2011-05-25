RSpec.configure do |config|
#Spec::Runner.configure do |config|
  config.mock_with :rspec
end


require File.join(File.expand_path('../..', __FILE__), 'app', 'init')

