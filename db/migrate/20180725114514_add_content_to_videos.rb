class AddContentToVideos < ActiveRecord::Migration[5.1]
  def change
    add_column :videos, :content, :text, limit: 2147483647 #, null: false, default: ''
    add_column :videos, :content_sanitizer_version, :integer, limit: 2, default: 0, null: false
    add_column :videos, :embed_id, :string
    add_column :videos, :embed_site, :string
    add_column :videos, :embed_pass, :string

    add_index :videos, :embed_site
    add_index :works, [:type, :id]
  end
end
