class Note < ActiveRecord::Base
  validates_uniqueness_of :title

  def to_simplenote_content
    title + "\n\n" + body.strip
  end
end
