class AddMultimediaOptionsToWorks < ActiveRecord::Migration[5.1]
  def change
    add_column :works, :type, :string, default: 'TextWork', null: false
    add_column :works, :duration, :integer, default: 0, null: false
  end
end
