class AddSlugToFandomTags < ActiveRecord::Migration
  def self.up
    add_column :fandom_tags, :slug, :string, null: false
    
    FandomTag.all.each do |ftag|
      ftag.slug = ftag.name.parameterize
      ftag.save
    end
    
    add_index :fandom_tags, :slug, unique: true
  end

  def self.down
    remove_column :fandom_tags, :slug
  end
end
