class Note < ActiveRecord::Base
  acts_as_paranoid
  scope :modified_locally, {:conditions => {:modified_locally => true}}
  validates_uniqueness_of :simplenote_key, :allow_nil => true

  def to_simplenote_content
    title + "\n\n" + body.strip
  end
end
