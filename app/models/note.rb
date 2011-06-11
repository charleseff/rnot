class Note < ActiveRecord::Base
  validates_uniqueness_of :title
  scope :modified_locally, {:conditions => {:modified_locally => true}}

  def to_simplenote_content
    title + "\n\n" + body.strip
  end
end
