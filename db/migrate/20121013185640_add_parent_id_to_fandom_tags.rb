class AddParentIdToFandomTags < ActiveRecord::Migration
  def self.up
    add_column :fandom_tags, :parent_id, :integer
  end

  def self.down
    remove_column :fandom_tags, :parent_id
  end
end
