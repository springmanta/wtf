class AddAssistsToAppearances < ActiveRecord::Migration[8.0]
  def change
    add_column :appearances, :assists, :integer, null: false, default: 0
  end
end
