class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :sender_id, index: true
      t.integer :recipient_id, index: true
      t.string :title
      t.text :body
      t.integer :thread_id, index: true
      t.string :type
      t.boolean :read, null: false, default: false
      t.boolean :replied_to, null: false, default: false

      t.timestamps
    end
  end
end
