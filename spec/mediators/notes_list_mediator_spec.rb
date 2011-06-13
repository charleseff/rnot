require 'spec_helper'

describe NotesListMediator do
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

        it 'should set search entry value to the note title' do
          @app.search_text_entry.text = 'some other thing'
          iter = @app.treeview.model.get_iter('0')
          @app.treeview.selection.select_iter(iter)
          expect { @app.treeview.signal_emit("cursor-changed") }.to change { @app.search_text_entry.text }.from('some other thing').to(iter[App::TITLE])

        end
      end

      describe "key-press-event" do
        context "keyval is a delete" do
          before do
            @event_key = Gdk::EventKey.new(Gdk::Event::KEY_PRESS)
            @event_key.keyval = 65535
          end
          context "note is selected" do
            before do
              iter = @app.notes_list_store.get_iter('0')
              @app.treeview.selection.select_iter iter
              @app.treeview.signal_emit('cursor-changed')
              @note = Note.find(iter[App::ID])

            end

            it "sets the deleted_at value for the note" do
              expect { @app.treeview.signal_emit("key-press-event", @event_key) }.to change { @note.reload.deleted_at.present? }.from(false).to(true)
            end
            it "adds sets modified_locally" do
              expect { @app.treeview.signal_emit("key-press-event", @event_key) }.to change { @note.reload.modified_locally }.from(false).to(true)
            end
          end

          context "no note is selected" do
            it "doesn't change the note count" do
              expect { @app.treeview.signal_emit("key-press-event", @event_key) }.to_not change { Note.count }
            end
          end

        end
      end

    end
  end

  describe '#refresh_notes' do
    context "refresh_notes doesn't remove note" do
      it 'should keep iter selected on treeview after called' do
        @app.refresh_notes
        @app.treeview.selection.select_iter @app.notes_list_store.get_iter('0')
        @app.treeview.selection.selected.should be_present

        expect { @app.refresh_notes }.to_not change { @app.treeview.selection.selected.present? }
      end
    end
  end

end