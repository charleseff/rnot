module NoteEditMediator
  include Gtk

  attr_accessor :text_edit_view

  def create_text_edit_window
    @text_edit_view = TextView.new
    @text_edit_view.wrap_mode = Gtk::TextTag::WRAP_WORD
    @text_edit_view.buffer.text = ""
    text_view_scrolled_win = ScrolledWindow.new
    text_view_scrolled_win.border_width = 5
    text_view_scrolled_win.add(@text_edit_view)
    text_view_scrolled_win.set_policy(POLICY_AUTOMATIC, POLICY_ALWAYS)

    text_view_scrolled_win
  end

  def save_note_if_open_and_changed
    if open_note.present? && open_note.body != text_edit_view.buffer.text
      open_note.update_attributes(:body => text_edit_view.buffer.text, :modified_locally => true,
                                  :modified_at => Time.now)

      # update the GUI to reflect new modified date:

      update_note_in_view_if_present(open_note)
    end
  end

  private
  def clear_open_note
    save_note_if_open_and_changed
    @open_note = nil
    text_edit_view.buffer.text = ''
  end

end