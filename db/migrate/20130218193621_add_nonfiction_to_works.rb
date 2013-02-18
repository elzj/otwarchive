class AddNonfictionToWorks < ActiveRecord::Migration
  def self.up
    add_column :works, :nonfiction, :boolean, null: false, default: false
  end

  def self.down
    remove_column :works, :nonfiction
  end
end
