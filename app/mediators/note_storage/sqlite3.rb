module NoteStorage::Sqlite3
  include NotesListMediator

  def refresh_notes(notes = Note.all)
    notes_list_store.clear
    notes.each do |note|
      iter = notes_list_store.append
      notes_list_store.set_value(iter, TITLE, note.title)
      notes_list_store.set_value(iter, MODIFIED, note.updated_at.to_s)
      notes_list_store.set_value(iter, ID, note.id)
    end
  end

  def handle_notes_list_cursor_change(treeview)
    if treeview.selection.selected.present?
      save_note_if_open_and_changed

      @open_note = Note.find(treeview.selection.selected[App::ID])
      text_edit_view.buffer.text = @open_note.body
      @search_text = treeview.selection.selected[App::TITLE]
      @search_text_entry.text = treeview.selection.selected[App::TITLE]
    else
      clear_open_note
    end

  end

  def save_note_if_open_and_changed
    if open_note.present? && open_note.body != text_edit_view.buffer.text
      open_note.update_attributes(:body => text_edit_view.buffer.text)

      notes_list_store.each do |model, path, iter|
        if iter[ID] == open_note.id
          iter[MODIFIED] = open_note.updated_at.to_s
          break
        end
      end
    end
  end
end