require 'spec_helper'

describe SearchTextMediator do
  before :each do
    @app = App.new
  end

  describe "treeview" do
    describe 'signals' do
      describe "cursor-changed" do
        it 'should attempt to save' do
          @app.should_receive(:save_note_if_open_and_changed).exactly(1).times

          iter = @app.treeview.model.get_iter('0')
          @app.treeview.selection.select_iter(iter)

          @app.treeview.signal_emit("cursor-changed")
        end
      end
    end
  end

end