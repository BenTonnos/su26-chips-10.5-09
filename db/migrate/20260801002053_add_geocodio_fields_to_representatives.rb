class AddGeocodioFieldsToRepresentatives < ActiveRecord::Migration[7.2]
  def change
    add_column :representatives, :birthday, :date
    add_column :representatives, :gender, :string
    add_column :representatives, :address, :string
    add_column :representatives, :phone, :string
    add_column :representatives, :contact_form_url, :string
    add_column :representatives, :website, :string
    add_column :representatives, :twitter, :string
    add_column :representatives, :facebook, :string
    add_column :representatives, :youtube, :string
    add_column :representatives, :bioguide_id, :string
  end
end
