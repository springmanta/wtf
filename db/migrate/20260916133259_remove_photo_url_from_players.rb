class RemovePhotoUrlFromPlayers < ActiveRecord::Migration[8.0]
  def change
    remove_column :players, :photo_url, :string
  end
end
