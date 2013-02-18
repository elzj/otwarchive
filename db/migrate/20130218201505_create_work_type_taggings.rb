class CreateWorkTypeTaggings < ActiveRecord::Migration
  def self.up
    create_table :work_type_taggings do |t|
      t.references :work
      t.references :work_type

      t.timestamps
    end
    add_index :work_type_taggings, [:work_id, :work_type_id], unique: true
    add_index :work_type_taggings, :work_type_id
  end

  def self.down
    drop_table :work_type_taggings
  end
end
