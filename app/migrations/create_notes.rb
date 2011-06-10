class CreateNotes < ActiveRecord::Migration
  def self.up
    create_table :notes do |t|
      t.string :title
      t.text :body
      t.string :simplenote_key
      t.integer :simplenote_syncnum
      t.boolean :modified_locally, :default => false
      
      t.timestamps
    end
  end

  def self.down
    drop_table :notes
  end
end
