#!/usr/bin/env ruby

ENV["RNOT_ENV"] = 'production'
require File.join(File.expand_path('..', __FILE__), 'app', 'init')
app = App.new
app.window.show_all
app.paned.position = app.paned.max_position/2
Gtk.main