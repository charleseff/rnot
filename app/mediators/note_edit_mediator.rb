module NoteEditMediator
  include Gtk

  attr_accessor :text_edit_view

  def create_text_edit_scrolled_window
    @text_edit_view = TextView.new
    @text_edit_view.buffer.text = ""
    text_view_scrolled_win = ScrolledWindow.new
    text_view_scrolled_win.border_width = 5
    text_view_scrolled_win.add(@text_edit_view)
    text_view_scrolled_win.set_policy(POLICY_AUTOMATIC, POLICY_ALWAYS)

    text_view_scrolled_win
  end
end