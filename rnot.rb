#!/usr/bin/env ruby

require File.join(File.expand_path('..', __FILE__), 'app', 'init')
app = App.new
app.window.show_all
Gtk.main