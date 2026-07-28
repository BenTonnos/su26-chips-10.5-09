class AddPhotoUrlToRepresentatives < ActiveRecord::Migration[7.2]
  def change
    add_column :representatives, :photo_url, :string
  end
end
