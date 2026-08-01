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

  describe '.geocodio_search' do
    let(:client) { instance_double(Geocodio::Gem) }

    before do
      allow(ENV).to receive(:fetch).and_return('fake_api_key')
      allow(Geocodio::Gem).to receive(:new).with('fake_api_key').and_return(client)
      allow(client).to receive(:geocode)
        .with('City, ST', ['cd'])
        .and_return('fake response')
    end

    it 'uses the Geocodio client to geocode an address' do
      expect(described_class.geocodio_search('City, ST')).to eq('fake response')
    end

    it 'raises an error when the API key is missing' do
      allow(ENV).to receive(:fetch).and_return(nil)
      expect do
        described_class.geocodio_search('City, ST')
      end.to raise_error(ArgumentError, 'Missing GEOCODIO_API_KEY')
    end
  end

  describe '.civic_api_to_representative_params' do
    let(:rep_info) do
      {
        'results' => [{
          'response' => {
            'results' => [{
              'fields' => {
                'congressional_districts' => [{
                  'current_legislators' => [{
                    'bio' => {
                      'first_name' => 'Jane',
                      'last_name' => 'Doe'
                    },
                    'type' => 'Representative',
                    'govtrack_id' => '123'
                  }]
                }]
              }
            }]
          }
        }]
      }
    end

    before do
      allow(described_class).to receive(:find_rep).and_return('Ben Tonnos')
    end

    it 'converts data into representatives' do
      expect(described_class.civic_api_to_representative_params(rep_info))
        .to eq(['Ben Tonnos'])

      expect(described_class).to have_received(:find_rep)
    end
  end
end
