require "rubygems"
require "bundler"
dir = File.expand_path('..', __FILE__)
ENV['BUNDLE_GEMFILE'] = File.join(dir, '..', 'Gemfile')
Bundler.require(:default, ENV["RNOT_ENV"].to_sym)

Dir.glob(File.join(dir, '..', 'lib', '*.rb')).each { |file| require file }

include AutoloadFor
autoload_for(File.join(dir, 'mediators'))
autoload_for(File.join(dir, 'models'))
autoload_for(File.join(dir, 'migrations'))
