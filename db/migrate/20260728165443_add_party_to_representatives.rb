# frozen_string_literal: true

class AddPartyToRepresentatives < ActiveRecord::Migration[7.2]
  def change
    add_column :representatives, :party, :string
  end
end
