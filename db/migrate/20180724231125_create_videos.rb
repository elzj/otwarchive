class CreateVideos < ActiveRecord::Migration[5.1]
  def change
    create_table :videos do |t|
      t.references :work, null: false #, foreign_key: true
      t.integer :duration, default: 0, null: false

      # Make this generally consistent with chapters
      t.integer  "position", :default => 1
      t.boolean  "posted", default: false, null: false
      t.string   "title"
      t.text     "notes"
      t.text     "summary"
      t.boolean  "hidden_by_admin", default: false, null: false
      t.date     "published_at"
      t.text     "endnotes"
      t.integer  "notes_sanitizer_version",    limit: 2, default: 0, null: false
      t.integer  "summary_sanitizer_version",  limit: 2, default: 0, null: false
      t.integer  "endnotes_sanitizer_version", limit: 2, default: 0, null: false

      t.timestamps
    end
  end
end
