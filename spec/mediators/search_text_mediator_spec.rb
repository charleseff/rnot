require 'spec_helper'

describe SearchTextMediator do
  before :each do
    @app = App.new
  end

  describe 'signals' do
    describe "key-release-event" do
      it "should change search_text to value of text entry" do
        @app.search_text_entry.text = 'blady'

        expect { @app.search_text_entry.signal_emit("key-release-event", Gdk::EventKey.new(Gdk::Event::KEY_PRESS)) }.
            to change { @app.last_searched_text }.from(nil).to('blady')
      end

      context "text is a match of one of the notes' titles/content" do
        before do
          @note = Factory(:note, :updated_at => Time.now-1.day, :created_at => Time.now-1.day,
                          :modified_at => Time.now-1.day)
          @app.search_text_entry.text = 'BLLLARGHHH'
          @app.refresh_notes

          @app.search_text_entry.text = @note.title
        end

        it "should highlight that note in the notes list" do
          expect { @app.search_text_entry.signal_emit("key-release-event", nil) }.to change {
            @app.treeview.selection.selected }.to(@app.iter_for_note(@note))
        end
        it "should set the text_edit_view to be that note's contents" do
          expect { @app.search_text_entry.signal_emit("key-release-event", nil) }.to change {
            @app.text_edit_view.buffer.text }.to(@note.body)
        end
      end
    end

    describe "key-press-event" do
      context "enter is pressed" do
        before do
          @app.treeview.selection.unselect_all

          @app.search_text_entry.text = 'foobar'
          @event_key = Gdk::EventKey.new(Gdk::Event::KEY_PRESS)
          @event_key.keyval = 65421
        end
        it "creates a new note when there is no selected value in the note-list view" do
          expect { @app.search_text_entry.signal_emit("key-press-event", @event_key) }.to change { Note.count }.by(1)
        end

        it "creates a new note with title set" do
          @app.search_text_entry.signal_emit("key-press-event", @event_key)
          Note.last.title.should == 'foobar'
        end

        it "create a new note with body set to blank" do
          @app.search_text_entry.signal_emit("key-press-event", @event_key)
          Note.last.body.should == ''
        end

        it "create a new note with modified_locally set to true" do
          @app.search_text_entry.signal_emit("key-press-event", @event_key)
          Note.last.modified_locally.should be_true
        end
        it "create a new note with modified_at set to Time.now" do
          @app.search_text_entry.signal_emit("key-press-event", @event_key)
          Note.last.modified_at.should be_within(1.second).of(Time.now)
        end
      end
    end

  end

end