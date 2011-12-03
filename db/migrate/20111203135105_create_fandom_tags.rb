class CreateFandomTags < ActiveRecord::Migration
  def self.up
    create_table :fandom_tags do |t|
      t.string :name
      t.string :type
      t.boolean :featured

      t.timestamps
    end
    add_index :fandom_tags, :name, :unique => true
    add_index :fandom_tags, :type
    add_index :fandom_tags, :featured
  end

  def self.down
    drop_table :fandom_tags
  end
end
