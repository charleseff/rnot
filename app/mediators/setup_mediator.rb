class SetupMediator
  def self.setup_directories
    rnot_dir = File.join(ENV['HOME'], '.rnot')
    unless FileTest::exists? rnot_dir
      Dir.mkdir rnot_dir
      Dir.mkdir File.join(rnot_dir, 'notes')
    end
  end
end