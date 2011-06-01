module NotesListMediator
  include Gtk

  TITLE = 0
  MODIFIED = 1
  ID = 2

  attr_accessor :treeview, :notes_list_store

  def create_notes_list_scrolled_window
    @treeview = TreeView.new
    setup_tree_view(@treeview)
    @notes_list_store = ListStore.new(String, String, Integer)

    @treeview.model = @notes_list_store

    scrolled_win = ScrolledWindow.new
    scrolled_win.add(@treeview)
    scrolled_win.set_policy(POLICY_AUTOMATIC, POLICY_AUTOMATIC)

    scrolled_win
  end

  private
  def setup_tree_view(treeview)
    renderer = CellRendererText.new
    column = TreeViewColumn.new("Title", renderer, "text" => TITLE)
    column.sort_column_id = TITLE
    treeview.append_column(column)
    renderer = CellRendererText.new
    column = TreeViewColumn.new("Date Modified", renderer, "text" => MODIFIED)
    column.sort_column_id = MODIFIED
    treeview.append_column(column)

    treeview.signal_connect("key-press-event") do |window, event_key|
      if [65421, 65293].include? event_key.keyval # return and keyboard return
        text_edit_view.grab_focus
      end
    end
    treeview.signal_connect('cursor-changed') do |t, _|
      if t.selection.selected.present?
        save_note_if_open_and_changed

        @open_note = Note.find(t.selection.selected[App::ID])
        text_edit_view.buffer.text = @open_note.body
        @search_text = t.selection.selected[App::TITLE]
        @search_text_entry.text = t.selection.selected[App::TITLE]
      else
        clear_open_note
      end

    end
  end

  def refresh_notes(notes = Note.all, selected_note = nil)
    notes_list_store.clear
    notes.each do |note|
      iter = notes_list_store.append
      notes_list_store.set_value(iter, TITLE, note.title)
      notes_list_store.set_value(iter, MODIFIED, note.updated_at.to_s)
      notes_list_store.set_value(iter, ID, note.id)
      if selected_note == note
        treeview.selection.select_iter iter
        @open_note = Note.find(treeview.selection.selected[App::ID])
        text_edit_view.buffer.text = @open_note.body
      end
    end

  end

  def handle_notes_list_cursor_change(treeview)
  end


end