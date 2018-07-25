class AddAttachmentsToVideos < ActiveRecord::Migration[5.1]
  def change
    add_attachment :videos, :video_file
    add_column :videos, :video_file_meta, :string
    add_column :videos, :video_file_processing, :boolean, null: false, default: false
  end
end
