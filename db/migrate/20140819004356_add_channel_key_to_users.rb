class AddChannelKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :channel_key, :string, null: false, default: '', index: true
  end
end
