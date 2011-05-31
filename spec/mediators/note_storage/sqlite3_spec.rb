require 'spec_helper'

describe NoteStorage::Sqlite3 do
  before :each do
    2.times { Factory.create(:note, :updated_at => Time.now-1.day, :created_at => Time.now-1.day) }
    @app = App.new
  end

  describe "save_note_if_open_and_changed" do
    context "note is saved" do
      before do
        @iter = @app.treeview.model.get_iter('0')
        @app.open_note = Note.find(@iter[App::ID])
        @note = @app.open_note
        @app.text_edit_view.buffer.text = 'Something different'
      end

      it "changes the body of the note" do
        body_before = @note.body
        expect { @app.save_note_if_open_and_changed }.to change { @note.reload.body }.from(body_before).to('Something different')
      end
      it "changes the modified value in the notes list" do
           expect { @app.save_note_if_open_and_changed }.to change { @iter[App::MODIFIED] }
      end
    end
  end

end