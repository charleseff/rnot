class Note < ActiveRecord::Base
  validates_uniqueness_of :title
end
