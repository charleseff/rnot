class App
  include Gtk

  include SearchTextMediator
  include NotesListMediator
  include NoteEditMediator
  include Rnot::Config

  attr_accessor :window, :open_note, :paned, :simplenote

  def initialize
    FileUtils.mkdir_p(App.notes_dir)
    setup_database
    setup_window
    self.config_hash = {:simplenote => {:enabled => false}} if config_hash.blank?

    if simplenote_enabled?
      @simplenote = SimplenoteMediator.new(self)
      setup_simplenote_timer if ENV["RNOT_ENV"] == 'production'
    end

    refresh_notes
  end

  def setup_simplenote_timer
    Thread.abort_on_exception = true
    @simplenote_thread = Thread.new do
      while simplenote_enabled? do
        puts "Simplenote syncing"
        @simplenote.sync

        sleep(60)
      end
    end

  end

  def self.database_path
    @database_path ||= File.join(notes_dir, 'rnot.sqlite3')
  end

  def self.database_config
    @database_config ||= {:database => database_path, :adapter => 'sqlite3'}
  end

  def self.notes_dir
    @notes_dir ||= lambda {
      rnot_dir = File.join(ENV['HOME'], '.rnot')
      dir = if ['production', 'console'].include? ENV["RNOT_ENV"]
              File.join(rnot_dir, 'notes')
            else
              File.join(rnot_dir, 'notes-test')
            end
      dir
    }.call
  end

  def internet_connection?
    Ping.pingecho "google.com", 1, 80
  end

  def simplenote_enabled?
    config_hash[:simplenote][:enabled] == true
  end

  private
  def setup_database
    ActiveRecord::Base.establish_connection(App.database_config)
    CreateNotes.up unless Note.table_exists?
  end

  def setup_window
    @window = Window.new(Gtk::Window::TOPLEVEL)
    @window.resizable = true
    @window.title = "RNot"
    @window.signal_connect("delete_event") do
      false
    end
    @window.signal_connect("destroy") do
      @simplenote.push if simplenote_enabled? && internet_connection?
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

    create_search_text_entry
    box1.pack_start(@search_text_entry, false, true, 5)

    text_edit_scrolled_window = create_text_edit_scrolled_window
    notes_list_scrolled_window = create_notes_list_scrolled_window

    @paned = VPaned.new
    @paned.pack1(notes_list_scrolled_window, true, true)
    @paned.pack2(text_edit_scrolled_window, true, true)

    box1.pack_start(@paned, true, true, 0)
    @paned.position = @paned.max_position * 0.5

    @window.add(box1)

  end

  def create_global_accel_keys_and_menus
    @main_accel_group = AccelGroup.new
    menubar = Gtk::MenuBar.new

    menu_menu = Gtk::Menu.new
    menu_m = Gtk::MenuItem.new "Menu"
    menu_m.set_submenu menu_menu

    help = Gtk::MenuItem.new("Help", true)
    help.signal_connect('activate') do |f, s|
      puts 'help activated'
      dialog = Dialog.new
      label = Gtk::Label.new(File.open(File.join(File.expand_path('../../../', __FILE__), 'README.md')).read)
      label.wrap = true
      dialog.vbox.add(label)

      dialog.show_all
      dialog.run
      dialog.destroy
    end
    menu_menu.append help

    options = Gtk::MenuItem.new("Options", true)
    options.signal_connect('activate') do |f, s|
      dialog = Dialog.new

      check_button = CheckButton.new("Simplenote integration")
      dialog.vbox.add(check_button)

      label = Gtk::Label.new("email:")
      email_entry = Entry.new()
      hbox = HBox.new(false, 0)
      hbox.pack_start(label)
      hbox.pack_start(email_entry)
      dialog.vbox.add(hbox)

      label = Gtk::Label.new("password:")
      password_entry = Entry.new()
      hbox = HBox.new(false, 0)
      hbox.pack_start(label)
      hbox.pack_start(password_entry)
      dialog.vbox.add(hbox)

      button = Button.new("Save")
      dialog.vbox.add(button)

      button.signal_connect("clicked") do

        if check_button.active?
          @simplenote = SimplenoteMediator.new(self, email_entry.text, password_entry.text)
          begin
            @simplenote.simplenote.login
            setup_simplenote_timer if ENV["RNOT_ENV"] == 'production'
            encrypt_simplenote_password
            self.config_hash = config_hash.merge(:simplenote=>{:enabled=>true, :email=>email_entry.text})
            msg = MessageDialog.new(dialog, Gtk::Dialog::MODAL,
                                    Gtk::MessageDialog::INFO,
                                    Gtk::MessageDialog::BUTTONS_OK,
                                    "Simplenote connection established.")
            msg.run
            msg.destroy
          rescue
            msg = MessageDialog.new(dialog, Gtk::Dialog::MODAL,
                                    Gtk::MessageDialog::INFO,
                                    Gtk::MessageDialog::BUTTONS_OK,
                                    "Simplenote login failed.")
            msg.run
            msg.destroy
          end
        else
          self.config_hash = config_hash.merge(:simplenote=>{:enabled=>false})
        end
=begin
        find = entry.text
        first, last, success = @text_edit_view.buffer.selection_bounds

        first = @text_edit_view.buffer.start_iter unless success

        first, last = first.forward_search(find, Gtk::TextIter::SEARCH_TEXT_ONLY, last)

        # Select the instance on the screen if the string is found.
        # Otherwise, tell the user it has failed.
        if (first)
          mark = @text_edit_view.buffer.create_mark(nil, first, false)
          # Scrolls the Gtk::TextView the minimum distance so
          # that mark is contained within the visible area.
          @text_edit_view.scroll_mark_onscreen(mark)

          @text_edit_view.buffer.delete_mark(mark)
          @text_edit_view.buffer.select_range(first, last)
        else
          # Gtk::MessageDialog.new(parent, flags, message_type, button_type, message = nil)
          dialogue = Gtk::MessageDialog.new(
              nil,
              Gtk::Dialog::MODAL,
              Gtk::MessageDialog::INFO,
              Gtk::MessageDialog::BUTTONS_OK,
              "The text was not found!"
          )
          dialogue.run
          dialogue.destroy
        end
        first = last = nil # caccel any previous selections
=end
      end

      dialog.show_all
      dialog.run
      dialog.destroy
    end
    menu_menu.append(options)

    menubar.append menu_m

    window.add_accel_group(@main_accel_group)

    # ctrl-L:
    @main_accel_group.connect(Gdk::Keyval::GDK_L, Gdk::Window::CONTROL_MASK,
                              ACCEL_VISIBLE) do
      search_text_entry.grab_focus
    end
    @main_accel_group.connect(Gdk::Keyval::GDK_F, Gdk::Window::CONTROL_MASK,
                              ACCEL_VISIBLE) do
      if text_edit_view.focus?
        dialog = Dialog.new
        box1 = HBox.new(false, 0)

        entry = Entry.new
        entry.text = "Search for ..."
        find_button = Button.new(Gtk::Stock::FIND)
        entry.signal_connect("key-press-event") do |e, event_key|
          if [65421, 65293].include? event_key.keyval # return and keyboard return
            find_button.clicked
          end

        end

        find_button.signal_connect("clicked") do

          find = entry.text
          first, last, success = @text_edit_view.buffer.selection_bounds

          first = @text_edit_view.buffer.start_iter unless success

          first, last = first.forward_search(find, Gtk::TextIter::SEARCH_TEXT_ONLY, last)

          # Select the instance on the screen if the string is found.
          # Otherwise, tell the user it has failed.
          if (first)
            mark = @text_edit_view.buffer.create_mark(nil, first, false)
            # Scrolls the Gtk::TextView the minimum distance so
            # that mark is contained within the visible area.
            @text_edit_view.scroll_mark_onscreen(mark)

            @text_edit_view.buffer.delete_mark(mark)
            @text_edit_view.buffer.select_range(first, last)
          else
            # Gtk::MessageDialog.new(parent, flags, message_type, button_type, message = nil)
            dialogue = Gtk::MessageDialog.new(
                nil,
                Gtk::Dialog::MODAL,
                Gtk::MessageDialog::INFO,
                Gtk::MessageDialog::BUTTONS_OK,
                "The text was not found!"
            )
            dialogue.run
            dialogue.destroy
          end
          first = last = nil # caccel any previous selections
        end

        box1.pack_start(entry)
        box1.pack_start(find_button)
        dialog.vbox.add(box1)

        dialog.show_all
        dialog.run
        dialog.destroy
      end
    end

    menubar
  end


end
