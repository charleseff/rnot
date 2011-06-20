require "rubygems"
require "bundler"
Bundler.require(:default, ENV["RNOT_ENV"].to_sym)

dir = File.expand_path('..', __FILE__)

Dir.glob(File.join(dir, '..', 'lib', '*.rb')).each { |file| require file }

include AutoloadFor
autoload_for(File.join(dir, 'mediators'))
autoload_for(File.join(dir, 'models'))
autoload_for(File.join(dir, 'migrations'))
