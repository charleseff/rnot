#!/usr/bin/env ruby
require 'gtk2'

entry = Gtk::Entry.new

@search_text = nil

entry.signal_connect('key-release-event') do |entry, _|
  if @search_text != entry.text
    @search_text = entry.text
    puts "text changed to #{@search_text}"
  end
end

window = Gtk::Window.new
window.signal_connect("delete_event") {
  puts "delete event occurred"
  #true
  false
}

window.signal_connect("destroy") {
  puts "destroy event occurred"
  Gtk.main_quit
}

window.border_width = 10
window.add(entry)
window.show_all

Gtk.main