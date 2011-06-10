#!/usr/bin/env ruby
# USAGE:
# irb -r ./console.rb

ENV["RNOT_ENV"] = 'console'
require File.join(File.expand_path('..', __FILE__), 'app', 'init')
@app = App.new
