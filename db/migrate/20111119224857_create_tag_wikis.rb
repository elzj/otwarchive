class CreateTagWikis < ActiveRecord::Migration
  def self.up
    create_table :tag_wikis do |t|
      t.integer   :tag_id, :null => false
      t.string    :fanlore_link
      t.text      :description
      t.integer   :language_id
      t.string   "icon_file_name"
      t.string   "icon_content_type"
      t.integer  "icon_file_size"
      t.datetime "icon_updated_at"
      t.string   "icon_alt_text",                              :default => ""
      t.integer  "description_sanitizer_version", :limit => 2, :default => 0, :null => false
      
      t.timestamps
    end
    add_index :tag_wikis, :tag_id, :unique => true
  end

  def self.down
    drop_table :tag_wikis
  end
end
