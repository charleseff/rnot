require 'singleton'

class App
  include Singleton

  attr_accessor :search_text_entry
end