class CreateWorkTypes < ActiveRecord::Migration
  def self.up
    create_table :work_types do |t|
      t.string :name, null: false, default: ''
    end
    add_index :work_types, :name, unique: true
  end

  def self.down
    drop_table :work_types
  end
end
