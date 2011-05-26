class OpenNote
  attr_accessor :iter

  def initialize(iter)
    @iter = iter
  end

  def note
    @note = Note.find(iter[App::ID])
  end
end