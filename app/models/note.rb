class Note < ActiveRecord::Base
  scope :modified_locally, where(:modified_locally => true)
  scope :not_deleted, where(:deleted_at => nil)
  validates_uniqueness_of :simplenote_key, :allow_nil => true

  def to_simplenote_content
    title + "\n\n" + body.strip
  end

  def deleted?
    deleted_at.present?
  end
end
