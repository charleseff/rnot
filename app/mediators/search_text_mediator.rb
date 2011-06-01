module SearchTextMediator
  include Gtk

  attr_accessor :search_text, :search_text_entry

  def create_search_text_entry
    @search_text_entry = Entry.new
    @search_text_entry.signal_connect('key-release-event') do |e, _|
      if @search_text != e.text
        @search_text = e.text
        clear_open_note
        selected_note = nil
        notes_found = []
        Note.all.each do |n|
          if n.title.index(@search_text) || n.body.index(@search_text)
            notes_found << n
            selected_note = n if !selected_note.present? && n.title.index(@search_text)
          end
        end
        refresh_notes(notes_found, selected_note)
      end
    end

    @search_text_entry.signal_connect('key-press-event') do |e, event_key|
      @search_text = e.text
      if event_key.keyval == 65364 # down arrow
        treeview.set_cursor(TreePath.new(0), nil, false)
        treeview.grab_focus
      elsif [65421, 65293].include? event_key.keyval # return and keyboard return
        if !treeview.selection.selected.present?
          @open_note = Note.create!(:title => @search_text, :body => '')

          iter = notes_list_store.append
          notes_list_store.set_value(iter, App::TITLE, @open_note.title)
          notes_list_store.set_value(iter, App::MODIFIED, @open_note.updated_at.to_s)
          notes_list_store.set_value(iter, App::ID, @open_note.id)

          treeview.selection.select_iter iter
        end
        text_edit_view.grab_focus
      end

    end
  end


end