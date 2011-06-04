require 'spec_helper'

describe SearchTextMediator do
  before :each do
    2.times { Factory(:note) }
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

      it 'should set search entry value to the note title' do
        @app.search_text_entry.text = 'some other thing'
        iter = @app.treeview.model.get_iter('0')
        @app.treeview.selection.select_iter(iter)
        expect { @app.treeview.signal_emit("cursor-changed") }.to change { @app.search_text_entry.text }.from('some other thing').to(iter[App::TITLE])

      end
    end
  end

end