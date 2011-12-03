class CreateFandomTaggings < ActiveRecord::Migration
  def self.up
    create_table :fandom_taggings do |t|
      t.integer :fandom_id
      t.integer :fandom_tagger_id
      t.string :fandom_tagger_type

      t.timestamps
    end
    add_index :fandom_taggings, :fandom_id
    add_index :fandom_taggings, [:fandom_tagger_id, :fandom_tagger_type], :name => "fandom_taggings_tag"
  end

  def self.down
    drop_table :fandom_taggings
  end
end
