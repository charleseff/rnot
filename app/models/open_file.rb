class OpenFile
  attr_accessor :file_name, :saved_text
  def initialize(f, s)
    @file_name = f; @saved_text = s
  end
end