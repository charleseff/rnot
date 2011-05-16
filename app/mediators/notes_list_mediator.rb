class NotesListMediator
  TITLE = 0
  MODIFIED = 1

  def self.setup_tree_view(treeview)
    renderer = Gtk::CellRendererText.new
    column = Gtk::TreeViewColumn.new("Title", renderer, "text" => TITLE)
    treeview.append_column(column)
    renderer = Gtk::CellRendererText.new
    column = Gtk::TreeViewColumn.new("Date Modified", renderer, "text" => MODIFIED)
    treeview.append_column(column)
  end

  def self.create_notes_list_scrolled_window
    test_data = [
        {:title => "Foobar", :modified => DateTime.now},
        {:title => "Blahdy Blah", :modified => DateTime.now - 4.days},
    ]
    treeview = Gtk::TreeView.new
    setup_tree_view(treeview)
    store = Gtk::ListStore.new(String, String)
    test_data.each do |e|
      iter = store.append
      store.set_value(iter, TITLE, e[:title])
      store.set_value(iter, MODIFIED, e[:modified].to_s)
    end
    treeview.model = store

    scrolled_win = Gtk::ScrolledWindow.new
    scrolled_win.add(treeview)
    scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)

    scrolled_win
  end

  def self.get_notes

  end
end