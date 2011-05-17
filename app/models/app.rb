require 'singleton'

class App
  include NotesListMediator

  attr_accessor :search_text_entry, :notes_dir, :window, :notes_list_store

  def refresh_notes
    notes_list_store.clear
    files = Dir.glob((File.join(@notes_dir, "*"))).select { |x| test(?f, x) }
    files.each do |file|
      iter = notes_list_store.append
      notes_list_store.set_value(iter, TITLE, File.basename(file))
      notes_list_store.set_value(iter, MODIFIED, File.new(file).mtime.to_s)
    end
  end

  def initialize
    setup_directories
    setup_window
    create_global_accel_keys
    refresh_notes
    window.show_all
  end

  private
  def setup_directories
    rnot_dir = File.join(ENV['HOME'], '.rnot')
    @notes_dir = File.join(rnot_dir, 'notes')
    unless FileTest::exists? rnot_dir
      Dir.mkdir rnot_dir
      Dir.mkdir app.notes_dir
    end

  end

  def setup_window
    box1 = Gtk::VBox.new(false, 0)

    @search_text_entry = SearchTextMediator.create_search_text_entry
    box1.pack_start(@search_text_entry, true, true, 0)

    notes_list_scrolled_window = create_notes_list_scrolled_window
    box1.pack_start(notes_list_scrolled_window, true, true, 0)

    text_edit_scrolled_window = NoteEditMediator.create_text_edit_scrolled_window
    box1.pack_start(text_edit_scrolled_window, true, true, 0)

    @window = Gtk::Window.new
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

    @window.add(box1)
  end

  def create_global_accel_keys
    menu = Gtk::Menu.new

    focus = Gtk::MenuItem.new("Focus search text")
    menu.append(focus)

    # Create a keyboard accelerator group for the application.
    group = Gtk::AccelGroup.new
    window.add_accel_group(group)
    menu.accel_group=(group)

    # Add the necessary keyboard accelerators.
    focus.add_accelerator('activate', group, Gdk::Keyval::GDK_L,
                          Gdk::Window::CONTROL_MASK, Gtk::ACCEL_VISIBLE)
    focus.signal_connect('activate') do |_|
      puts "focus search text"
      app.search_text_entry.grab_focus
    end

    menu.show_all
  end

end