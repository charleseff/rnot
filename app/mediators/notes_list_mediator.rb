module NotesListMediator
  include Gtk

  TITLE = 0
  MODIFIED = 1

  def create_notes_list_scrolled_window
    @treeview = TreeView.new
    setup_tree_view(@treeview)
    store = ListStore.new(String, String)
    @notes_list_store = store
    @treeview.model = store

    @treeview.signal_connect('cursor-changed') do |e, _|
      if e.selection.selected.present?
        save_note_if_open_and_changed

        file_name = e.selection.selected.get_value(TITLE) + '.txt'
        saved_text = File.new(File.join(App.notes_dir, file_name), 'r').read
        @open_file = OpenFile.new(file_name, saved_text)
        text_edit_view.buffer.text = saved_text
      else
        @open_file = nil
      end
    end

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

  end


end