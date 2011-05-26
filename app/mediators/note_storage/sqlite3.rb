module NoteStorage::Sqlite3
  include NotesListMediator

  def refresh_notes
    notes_list_store.clear
    Note.all.each do |note|
      iter = notes_list_store.append
      notes_list_store.set_value(iter, TITLE, note.title)
      notes_list_store.set_value(iter, MODIFIED, note.updated_at.to_s)
      notes_list_store.set_value(iter, ID, note.id)
    end
  end

  def handle_notes_list_cursor_change(treeview)
    if treeview.selection.selected.present?
      save_note_if_open_and_changed

      @open_note = OpenNote.new(treeview.selection.selected)
      text_edit_view.buffer.text = @open_note.note.body
    else
      @open_note = nil
    end

  end

  def save_note_if_open_and_changed
    if open_note.present? && open_note.note.body != text_edit_view.buffer.text
      note = open_note.note
      note.update_attributes(:body => text_edit_view.buffer.text)

      open_note.iter[MODIFIED] = note.updated_at.to_s
    end
  end
end