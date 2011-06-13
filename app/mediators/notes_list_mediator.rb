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

  def refresh_notes(notes = Note.all, selected_note = nil)
    notes_to_add = notes.clone

    iters_to_remove = []
    notes_list_store.each do |model, path, iter|
      if note=notes_to_add.detect { |n| n.id == iter[App::ID] }
        notes_to_add.delete(note)
      else
        iters_to_remove << iter
      end
    end
    iters_to_remove.each { |iter| notes_list_store.remove(iter) }

    notes_to_add.each do |note|
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

  def refresh_notes_with_search_text(search_text,select_note=false)
    selected_note = nil
    notes_found = []
    Note.all.each do |n|
      if n.title.index(search_text) || n.body.index(search_text)
        notes_found << n
        #selected_note = n if !selected_note.present? && n.title.index(search_text)
        selected_note = n if select_note && !selected_note.present? && n.title.index(search_text)
      end
    end
    refresh_notes(notes_found, selected_note)
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
      elsif event_key.keyval == 65535 # delete
        if treeview.selection.selected.present?
          notes_list_store.remove  treeview.selection.selected
        # todo: should be a 'are you sure' popup dialog here..
        @open_note.update_attributes(:deleted_at => Time.now, :modified_locally => true, :modified_at => Time.now)
        end
      end
    end
    treeview.signal_connect('cursor-changed') do |t, _|
      if t.selection.selected.present?
        save_note_if_open_and_changed

        @open_note = Note.find(t.selection.selected[App::ID])
        text_edit_view.buffer.text = @open_note.body
        @title_of_open_note = t.selection.selected[App::TITLE]
        @search_text_entry.text = t.selection.selected[App::TITLE]
      else
        clear_open_note
      end

    end
  end

end