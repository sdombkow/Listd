class AddAttachmentPhotoToLocations < ActiveRecord::Migration
  def self.up
    change_table :locations do |t|
      t.attachment :photo
    end
  end

  def self.down
    drop_attached_file :locations, :photo
  end
end
