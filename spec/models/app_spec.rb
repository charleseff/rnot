require 'spec_helper'

describe App do

  before :each do
    @app = App.new
  end

  describe 'signals' do
    describe "key-release-event" do
      it "should change search_text to value of text entry" do

        main_accel_group = @app.instance_variable_get(:@main_accel_group)
        main_accel_group
=begin
        @app.search_text_entry.text = 'blady'

        expect { @app.search_text_entry.signal_emit("key-release-event", nil) }.
            to change { @app.search_text }.from(nil).to('blady')
=end
      end
    end

  end

end