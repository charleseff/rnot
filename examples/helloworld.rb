#!/usr/bin/env ruby
=begin
  helloworld.rb - Ruby/GTK first sample script.

  Copyright (c) 2002,2003 Ruby-GNOME2 Project Team
  This program is licenced under the same licence as Ruby-GNOME2.

  $Id: helloworld.rb,v 1.4 2003/02/01 16:46:22 mutoh Exp $
=end

require 'gtk2'

button = Gtk::Button.new("Hello World")
button.signal_connect("clicked")  { |w, e|
  puts "Hello World"
  puts w.inspect
  puts e.inspect
}

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
window.add(button)
window.show_all

Gtk.main