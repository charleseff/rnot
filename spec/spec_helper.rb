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
    Note.delete_all!
  end
end

ActiveRecord::Base.establish_connection(App.database_config)

VCR.config do |c|
  c.cassette_library_dir = File.join(File.expand_path('..', __FILE__), 'fixtures', 'vcr_cassettes')
  c.stub_with :fakeweb
  c.default_cassette_options = {:record => :once}
end

#helper:
def should_be_a_subset(superset, records_selected_by_scope, &condition)
  flunk "Your superset is empty" if superset.empty?
  flunk "Your scope did not select any records" if records_selected_by_scope.empty?

  records_selected_by_block, records_excluded_by_block = superset.partition(&condition)
  flunk "Your test condition did not select any records" if records_selected_by_block.empty?
  flunk "Your test condition did not exclude any records" if records_excluded_by_block.empty?

  records_selected_by_scope.map(&:id).should =~ records_selected_by_block.map(&:id)
end