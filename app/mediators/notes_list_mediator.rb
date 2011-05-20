module NotesListMediator
  TITLE = 0
  MODIFIED = 1

  def setup_tree_view(treeview)
    renderer = Gtk::CellRendererText.new
    column = Gtk::TreeViewColumn.new("Title", renderer, "text" => TITLE)
    treeview.append_column(column)
    renderer = Gtk::CellRendererText.new
    column = Gtk::TreeViewColumn.new("Date Modified", renderer, "text" => MODIFIED)
    treeview.append_column(column)
  end

  def create_notes_list_scrolled_window
    treeview = Gtk::TreeView.new
    setup_tree_view(treeview)
    store = Gtk::ListStore.new(String, String)
    @notes_list_store = store
    treeview.model = store

    treeview.signal_connect('cursor-changed') do |e, _|
      file_name= e.selection.selected.get_value(0)
      @current_text_saved = File.new(File.join(notes_dir, file_name), 'r').read
      text_edit_view.buffer.text = @current_text_saved
    end

    scrolled_win = Gtk::ScrolledWindow.new
    scrolled_win.add(treeview)
    scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

    scrolled_win
  end

end