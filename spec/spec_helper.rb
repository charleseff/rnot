ENV["RNOT_ENV"] = 'test'

require File.join(File.expand_path('../..', __FILE__), 'app', 'init')
require 'factories'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:all) do
    ActiveRecord::Base.establish_connection(App.database_config)

    CreateNotes.down
    CreateNotes.up
  end

  config.before(:each) do
    Note.destroy_all
  end
end

VCR.config do |c|
  c.cassette_library_dir = File.join(File.expand_path('..', __FILE__), 'fixtures', 'vcr_cassettes')
  c.stub_with :fakeweb
  c.default_cassette_options = {:record => :once}
end