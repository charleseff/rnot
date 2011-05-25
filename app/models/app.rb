class App
  include Gtk
  include SearchTextMediator
  include NotesListMediator
  include NoteEditMediator

  attr_accessor :search_text_entry, :window, :notes_list_store, :text_edit_view, :current_text_saved,
                :open_file, :treeview, :search_text, :paned

  def refresh_notes
    notes_list_store.clear
    files = Dir.glob((File.join(App.notes_dir, "*.txt"))).select { |x| test(?f, x) }
    files.each do |file|
      iter = notes_list_store.append
      notes_list_store.set_value(iter, TITLE, File.basename(file, '.*'))
      notes_list_store.set_value(iter, MODIFIED, File.new(file).mtime.to_s)
    end
  end

  def initialize
    setup_directories
    setup_database
    setup_window
#    create_global_accel_keys_and_menus
    refresh_notes
  end

  def self.database_path
    @database_path ||= lambda do
      if ENV["RNOT_ENV"] == 'production'
        File.join(notes_dir, 'rnot.sqlite3')
      else
        File.join(notes_dir, 'rnot.test.sqlite3')
      end
    end.call
  end

  def self.database_config
    @database_config ||= {:database => database_path, :adapter => 'sqlite3'}
  end

  def self.notes_dir
    @notes_dir ||= lambda {
      rnot_dir = File.join(ENV['HOME'], '.rnot')
      File.join(rnot_dir, 'notes')
    }.call
  end

  private
  def setup_database
    ActiveRecord::Base.establish_connection(App.database_config)
    CreateNotes.up unless Note.table_exists?
  end

  def setup_directories
    FileUtils.mkdir_p(App.notes_dir)
  end

  def setup_window
    @window = Window.new(Gtk::Window::TOPLEVEL)
    @window.resizable = true
    @window.title = "RNot"
    @window.signal_connect("delete_event") do
      puts "delete event occurred"
      false
    end
    @window.signal_connect("destroy") do
      puts "destroy event occurred"
      Gtk.main_quit
    end
    @window.set_size_request(750, 500)
    @window.border_width = 10
    @window.signal_connect("focus-out-event") do |e, _|
      save_note_if_open_and_changed
    end

    box1 = VBox.new(false, 0)

    menubar = create_global_accel_keys_and_menus
    box1.pack_start(menubar, false, true, 0)

    @search_text_entry = create_search_text_entry
    box1.pack_start(@search_text_entry, false, true, 5)

    text_edit_scrolled_window = create_text_edit_scrolled_window
    notes_list_scrolled_window = create_notes_list_scrolled_window

    @paned = VPaned.new
    @paned.add1(notes_list_scrolled_window)
    @paned.add2(text_edit_scrolled_window)

    box1.pack_start(@paned, true, true, 0)
    @paned.position = @paned.max_position/2

    @window.add(box1)

  end

  def create_global_accel_keys_and_menus
    @main_accel_group = AccelGroup.new
    menubar = Gtk::MenuBar.new

    filemenu = Gtk::Menu.new

    file = Gtk::MenuItem.new("File", true)

    file.submenu = filemenu

    menubar.append(file)

    filemenu.append(Gtk::ImageMenuItem.new(Gtk::Stock::NEW, @main_accel_group))

    window.add_accel_group(@main_accel_group)

    # ctrl-L:
    @main_accel_group.connect(Gdk::Keyval::GDK_L, Gdk::Window::CONTROL_MASK,
                              ACCEL_VISIBLE) do
      search_text_entry.grab_focus
    end


    menubar
  end

  def save_note_if_open_and_changed
    if open_file.present? && open_file.saved_text != text_edit_view.buffer.text
      File.open(File.join(notes_dir, open_file.file_name), 'w') { |f| f.write(text_edit_view.buffer.text) }
      open_file.saved_text = text_edit_view.buffer.text
    end

  end

end
