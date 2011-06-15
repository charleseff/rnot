module SearchTextMediator
  include Gtk

  attr_accessor :last_searched_text, :search_text_entry, :title_of_open_note

  def create_search_text_entry
    @search_text_entry = Entry.new
    @search_text_entry.signal_connect('key-release-event') do |e, _|

      if @last_searched_text != e.text and @open_note.try(:title) != e.text
        @last_searched_text = e.text
#        clear_open_note
        refresh_notes_with_search_text(@last_searched_text, true)
      end
    end

    @search_text_entry.signal_connect('key-press-event') do |e, event_key|
      if event_key.keyval == 65364 # down arrow
        treeview.set_cursor(TreePath.new(0), nil, false)
        treeview.grab_focus
      elsif [65421, 65293].include? event_key.keyval # return and keyboard return
        if !treeview.selection.selected.present?
          @open_note = Note.create!(:title => e.text, :body => '', :modified_locally => true,
                                    :modified_at => Time.now)

          iter = notes_list_store.append
          reload_values_for_iter(iter, @open_note)
          treeview.selection.select_iter iter
        end
        text_edit_view.grab_focus
      end

    end
  end


end