class AddFieldsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :user_id, :integer, null: false
    add_column :messages, :sender_name, :string
    add_column :messages, :recipient_name, :string
    add_column :messages, :parent_id, :integer
    add_column :messages, :parent_type, :string
    add_index :messages, [:parent_id, :parent_type]
  end
end
