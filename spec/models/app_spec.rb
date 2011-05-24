require 'spec_helper'

describe App do

  before :each do
    @app = App.new
  end

  describe 'signals' do
    describe "key-release-event" do
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
    end

  end

end