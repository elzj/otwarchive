class CreateExternalWorkTypeTaggings < ActiveRecord::Migration
  def self.up
    create_table :external_work_type_taggings do |t|
      t.references :external_work
      t.references :work_type

      t.timestamps
    end
    add_index :external_work_type_taggings, [:external_work_id, :work_type_id], unique: true, name: "external_work_types_unique"
    add_index :external_work_type_taggings, :work_type_id
  end

  def self.down
    drop_table :external_work_type_taggings
  end
end
