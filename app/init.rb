require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RNOT_ENV"].to_sym)
require 'gtk2'

include AutoloadFor
dir = File.expand_path('..', __FILE__)
autoload_for(File.join(dir, 'mediators'))
autoload_for(File.join(dir, 'models'))
autoload_for(File.join(dir, 'migrations'))
