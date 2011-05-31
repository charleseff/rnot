require 'spec_helper'

describe SearchTextMediator do
  before :each do
    @app = App.new
  end

  describe 'signals' do
    describe "key-release-event" do
      it "should change search_text to value of text entry" do
        @app.search_text_entry.text = 'blady'

        expect { @app.search_text_entry.signal_emit("key-release-event", nil) }.
            to change { @app.search_text }.from(nil).to('blady')
      end

      it 'should clear the open note' do
        @app.should_receive(:clear_open_note).exactly(1).times
        @app.search_text_entry.signal_emit("key-release-event", nil) #, 114)
      end
    end

  end

end