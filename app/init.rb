require "rubygems"
require "bundler"
dir = File.expand_path('..', __FILE__)
ENV['BUNDLE_GEMFILE'] = File.join(dir, '..', 'Gemfile')
Bundler.require(:default, ENV["RNOT_ENV"].to_sym)

Dir.glob(File.join(dir, '..', 'lib', '*.rb')).each { |file| require file }

require 'active_support/all'
require 'active_support/dependencies'
ActiveSupport::Dependencies.autoload_paths << File.join(dir, 'mediators')
ActiveSupport::Dependencies.autoload_paths << File.join(dir, 'models')
ActiveSupport::Dependencies.autoload_paths << File.join(dir, 'migrations')
