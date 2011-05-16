#!/usr/bin/env ruby
require 'gtk2'
require 'active_support/core_ext'
require File.join(File.dirname(__FILE__), '..', 'lib', 'autoload_for')

AutoloadFor.autoload_for(File.join(File.dirname(__FILE__), 'mediators'))

@search_text = nil
box1 = Gtk::VBox.new(false, 0)

search_text_entry = SearchTextMediator.create_search_text_entry
box1.pack_start(search_text_entry, true, true, 0)

notes_list_scrolled_window = NotesListMediator.create_notes_list_scrolled_window
box1.pack_start(notes_list_scrolled_window, true, true, 0)

text_edit_scrolled_window = TextEditMediator.create_text_edit_scrolled_window
box1.pack_start(text_edit_scrolled_window, true, true, 0)

window = Gtk::Window.new
window.resizable = true
window.title = "RNot"
window.signal_connect("delete_event") do
  puts "delete event occurred"
  false
end
window.signal_connect("destroy") do
  puts "destroy event occurred"
  Gtk.main_quit
end
window.set_size_request(250, 175)
window.border_width = 10

window.add(box1)
window.show_all

Gtk.main