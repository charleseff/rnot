module SearchTextMediator
  include Gtk

  def create_search_text_entry
    entry = Entry.new
    entry.signal_connect('key-release-event') do |e, _|
      if @search_text != e.text
        @search_text = e.text
      end
    end

    entry.signal_connect('key-press-event') do |e, event_key|
      if event_key.keyval == 65364
        treeview.set_cursor(TreePath.new(0), nil, false)
        treeview.grab_focus
      end
    end

    entry
  end


end