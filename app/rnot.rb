#!/usr/bin/env ruby

require "rubygems"
require "bundler/setup"
require 'gtk2'
require File.expand_path('../../lib/autoload_for', __FILE__)

AutoloadFor.autoload_for(File.join(File.expand_path('..', __FILE__), 'mediators'))
AutoloadFor.autoload_for(File.join(File.expand_path('..', __FILE__), 'models'))

#notes = NotesListMediator.get_notes
window = SetupMediator.new.setup
window.show_all

Gtk.main