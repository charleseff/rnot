require "rubygems"
require "bundler/setup"
require 'gtk2'
require 'autoload_for'

include AutoloadFor
autoload_for(File.join(File.expand_path('..', __FILE__), 'mediators'))
autoload_for(File.join(File.expand_path('..', __FILE__), 'models'))
