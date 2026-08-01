# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id         :integer          not null, primary key
#  name       :string
#  ocdid      :string
#  party      :string
#  photo_url  :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

# This file is a stub.
# You should add your own test cases.
# We recommend creating a file for each model in the database.

RSpec.describe Representative do
  describe '.find_rep' do
    it 'does not create duplicate representatives' do
      official = { 'name' => 'Francisco De La Riega', 'party' => 'Democratic', 'photo_url' => 'https://myimage.com/' }

      described_class.find_rep(official, title: 'Representative', ocdid: '12345')
      described_class.find_rep(official, title: 'Representative', ocdid: '12345')
      expect(described_class.count).to eq(1)
    end
  end
end
