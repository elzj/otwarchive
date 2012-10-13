class AddLockedToTagWikis < ActiveRecord::Migration
  def self.up
    add_column :tag_wikis, :locked, :boolean, null: false, default: false
  end

  def self.down
    remove_column :tag_wikis, :locked
  end
end
