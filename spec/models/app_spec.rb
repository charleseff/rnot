require 'spec_helper'

describe App do

  before :each do
    @app = App.new
  end

  describe 'signals' do
    context 'when Ctrl-L is pressed' do
      before do
        @keyval = Gdk::Keyval::GDK_L
      end
      it "should highlight text entry" do
        @app.text_edit_view.focus = true

        expect { Gtk::AccelGroup.activate(@app.window, @keyval, Gdk::Window::CONTROL_MASK) }.to
        change { @app.search_text_entry.focus? }.from(false).to(true)
      end
    end

    describe "focus-out-event" do
      it "should attempt to save note" do
        @app.should_receive(:save_note_if_open_and_changed).exactly(1).times
        @app.window.signal_emit("focus-out-event", nil)

      end
    end
  end

end