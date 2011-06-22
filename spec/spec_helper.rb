ENV["RNOT_ENV"] = 'test'

require File.join(File.expand_path('../..', __FILE__), 'app', 'init')
require 'factories'

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:each) do
    File.delete(App.config_file) if File.exists?(App.config_file)

    Note.destroy_all
  end
end

FileUtils.rm_rf(App.notes_dir)
FileUtils.mkdir_p(App.notes_dir)
ActiveRecord::Base.establish_connection(App.database_config)
CreateNotes.up

VCR.config do |c|
  c.cassette_library_dir = File.join(File.expand_path('..', __FILE__), 'fixtures', 'vcr_cassettes')
  c.stub_with :fakeweb
  c.default_cassette_options = {:record => :once}
end

Dir.glob(File.join(File.expand_path('..', __FILE__), 'spec_helpers','*.rb')).each { |file| require file }
