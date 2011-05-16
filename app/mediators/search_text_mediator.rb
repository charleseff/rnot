class SearchTextMediator

  def self.create_search_text_entry
    entry = Gtk::Entry.new
    entry.signal_connect('key-release-event') do |e, _|
      if @search_text != e.text
        @search_text = e.text
        puts "text changed to #{@search_text}"
      end
    end

    entry
  end
end