class SearchTextMediator

  def self.create_search_text_entry
    entry = Gtk::Entry.new
    entry.signal_connect('key-release-event') do |entry, _|
      if @search_text != entry.text
        @search_text = entry.text
        puts "text changed to #{@search_text}"
      end
    end

    entry
  end
end