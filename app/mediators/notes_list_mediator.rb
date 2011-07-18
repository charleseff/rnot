module NotesListMediator
  include Gtk

  TITLE = 0
  MODIFIED = 1
  ID = 2

  attr_accessor :treeview, :notes_list_store, :title_renderer

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

  def refresh_notes(notes = Note.not_deleted, selected_note = nil)
    notes_to_add = notes.to_a

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
      reload_values_for_iter(iter, note)
    end

    if selected_note.present?
      iter = iter_for_note(selected_note)
      treeview.selection.select_iter iter
      @open_note = selected_note
      text_edit_view.buffer.text = selected_note.body
    elsif treeview.selection.selected.blank?
      clear_open_note
    end


  end

  def refresh_notes_with_search_text(search_text, select_note=false)
    downcased_search_text = search_text.downcase
    selected_note = nil
    notes_found = []
    Note.not_deleted.each do |n|
      if n.title.downcase.index(downcased_search_text).present? || n.body.downcase.index(downcased_search_text).present?
        notes_found << n
        #selected_note = n if !selected_note.present? && n.title.index(search_text)
        selected_note = n if select_note && selected_note.blank? && n.title.downcase.index(downcased_search_text).present?
      end
    end

    refresh_notes(notes_found, selected_note)
  end

  def reload_values_for_iter(iter, note)
    notes_list_store.set_value(iter, TITLE, note.title)
    notes_list_store.set_value(iter, MODIFIED, note.modified_at.to_s)
    notes_list_store.set_value(iter, ID, note.id)
  end

  def remove_note_from_view(note)
    iter = iter_for_note(note)
    @notes_list_store.remove iter if iter.present?
  end

  def update_note_in_view_if_present(note)
    if iter=iter_for_note(note)
      reload_values_for_iter(iter, note)
    end
  end

  def add_note_to_view(note)
    iter = notes_list_store.append
    reload_values_for_iter(iter, note)
  end

  def iter_for_note(note)
    notes_list_store.each do |model, path, iter|
      return iter if iter[App::ID] == note.id
    end
    nil
  end

  private
  def setup_tree_view(treeview)
    @title_renderer = CellRendererText.new
    @title_renderer.editable = true
    column = TreeViewColumn.new("Title", @title_renderer, "text" => TITLE)
    column.sort_column_id = TITLE
    treeview.append_column(column)
    renderer = CellRendererText.new
    column = TreeViewColumn.new("Date Modified", renderer, "text" => MODIFIED)
    column.sort_column_id = MODIFIED
    treeview.append_column(column)

    @title_renderer.signal_connect("edited") do |renderer, iter_path, new_text|
      iter = treeview.model.get_iter(iter_path)
      iter[TITLE] = new_text
      Note.find(iter[App::ID]).update_attributes(:title => new_text, :modified_locally => true, :modified_at => Time.now)
    end

    treeview.signal_connect("key-press-event") do |treeview, event_key|
      if [65421, 65293].include? event_key.keyval # return and keyboard return
        text_edit_view.grab_focus
      elsif event_key.keyval == 65535 # delete
        if treeview.selection.selected.present?
          notes_list_store.remove treeview.selection.selected
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

        @search_text_entry.text = t.selection.selected[App::TITLE]
      else
        clear_open_note
      end

    end
  end

end