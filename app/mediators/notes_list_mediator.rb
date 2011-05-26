module NotesListMediator
  include Gtk

  TITLE = 0
  MODIFIED = 1
  ID = 2

  def create_notes_list_scrolled_window
    @treeview = TreeView.new
    setup_tree_view(@treeview)
    store = ListStore.new(String, String, Integer)
    @notes_list_store = store
    @treeview.model = store

    scrolled_win = ScrolledWindow.new
    scrolled_win.add(@treeview)
    scrolled_win.set_policy(POLICY_AUTOMATIC, POLICY_AUTOMATIC)

    scrolled_win
  end

  private
  def setup_tree_view(treeview)
    renderer = CellRendererText.new
    column = TreeViewColumn.new("Title", renderer, "text" => TITLE)
    treeview.append_column(column)
    renderer = CellRendererText.new
    column = TreeViewColumn.new("Date Modified", renderer, "text" => MODIFIED)
    treeview.append_column(column)

    treeview.signal_connect("key-press-event") do |window, event_key|
      if [65421, 65293].include? event_key.keyval # return and keyboard return
        text_edit_view.grab_focus
      end
    end
    treeview.signal_connect('cursor-changed') do |t, _|
      handle_notes_list_cursor_change(t)
    end


  end

end