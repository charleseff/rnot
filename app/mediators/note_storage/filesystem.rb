module NoteStorage::Filesystem
  include NotesListMediator

  def refresh_notes
    notes_list_store.clear
    files = Dir.glob((File.join(App.notes_dir, "*.txt"))).select { |x| test(?f, x) }
    files.each do |file|
      iter = notes_list_store.append
      notes_list_store.set_value(iter, TITLE, File.basename(file, '.*'))
      notes_list_store.set_value(iter, MODIFIED, File.new(file).mtime.to_s)
    end

  end

  def handle_notes_list_cursor_change(event)
    if event.selection.selected.present?
      save_note_if_open_and_changed
      file_name = event.selection.selected[TITLE] + '.txt'
      saved_text = File.new(File.join(App.notes_dir, file_name), 'r').read
      @open_note = OpenNote.new(file_name, saved_text)
      text_edit_view.buffer.text = saved_text
    else
      @open_note = nil
    end

  end


  def save_note_if_open_and_changed
    if open_note.present? && open_note.saved_text != text_edit_view.buffer.text
      File.open(File.join(notes_dir, open_note.file_name), 'w') { |f| f.write(text_edit_view.buffer.text) }
      open_note.saved_text = text_edit_view.buffer.text
    end

  end

end