class TextEditMediator
  def create_text_edit_scrolled_window
    text_view = Gtk::TextView.new
    text_view.buffer.text = "Your 1st Gtk::TextView widget!"
    text_view_scrolled_win = Gtk::ScrolledWindow.new
    text_view_scrolled_win.border_width = 5
    text_view_scrolled_win.add(text_view)
    text_view_scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_ALWAYS)

    text_view_scrolled_win
  end
end