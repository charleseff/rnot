module SearchTextMediator
  include Gtk

  attr_accessor :search_text, :search_text_entry

  def create_search_text_entry
    @search_text_entry = Entry.new
    @search_text_entry.signal_connect('key-release-event') do |e, _|
      if @search_text != e.text
        @search_text = e.text
        clear_open_note
        notes_found = Note.all.select do |n|
          n.title.index(@search_text) || n.body.index(@search_text)
        end
        refresh_notes(notes_found)
      end
    end

    @search_text_entry.signal_connect('key-press-event') do |e, event_key|
      if event_key.keyval == 65364 # down arrow
        treeview.set_cursor(TreePath.new(0), nil, false)
        treeview.grab_focus
      elsif       [65421, 65293].include? event_key.keyval # return and keyboard return
        # todo
      end

    end
  end


end