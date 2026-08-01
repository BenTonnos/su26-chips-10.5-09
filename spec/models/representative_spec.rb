# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id               :integer          not null, primary key
#  address          :string
#  birthday         :date
#  contact_form_url :string
#  facebook         :string
#  gender           :string
#  name             :string
#  ocdid            :string
#  party            :string
#  phone            :string
#  photo_url        :string
#  title            :string
#  twitter          :string
#  website          :string
#  youtube          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  bioguide_id      :string
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

  describe '#update_from_geocodio' do
    let(:full_official) do
      {
        'name' => 'Adam Choe',
        'type' => 'representative',
        'bio' => {
          'first_name' => 'Adam',
          'last_name' => 'Choe',
          'party' => 'Democratic',
          'birthday' => '2026-07-31',
          'gender' => 'M',
          'photo_url' => 'https://www.congress.gov/img/member/example.jpg'
        },
        'contact' => {
          'url' => 'https://bleacherreport.com',
          'address' => 'Bancroft Way',
          'phone' => '101-101-1001',
          'contact_form' => nil
        },
        'social' => {
          'twitter' => 'repachoe',
          'facebook' => 'repachoe',
          'youtube' => nil
        },
        'references' => {
          'bioguide_id' => 'D000896',
          'govtrack_id' => '000896'
        }
      }
    end
    let(:representative) { described_class.new }
    let(:minimal_official) do
      {
        'name' => 'Jane Doe',
        'type' => 'senator',
        'bio' => {
          'first_name' => 'Jane',
          'last_name' => 'Doe',
          'party' => 'Independent'
        }
      }
    end

    let(:representative_two) { described_class.new }

    before do
      representative.update_from_geocodio(full_official)
    end

    it 'sets personal information' do
      expect(representative.party).to eq('Democratic')
      expect(representative.birthday).to eq(Date.parse('2026-07-31'))
      expect(representative.gender).to eq('M')
    end

    it 'sets contact information' do
      expect(representative.address).to eq('Bancroft Way')
      expect(representative.phone).to eq('101-101-1001')
      expect(representative.website).to eq('https://bleacherreport.com')
    end

    it 'sets social information' do
      expect(representative.twitter).to eq('repachoe')
      expect(representative.facebook).to eq('repachoe')
      expect(representative.youtube).to be_nil
    end

    it 'sets reference information' do
      expect(representative.bioguide_id).to eq('D000896')
      expect(representative.ocdid).to eq('000896')
    end

    it 'handles missing optional blocks without errors' do
      expect { representative_two.update_from_geocodio(minimal_official) }
        .not_to raise_error
    end

    it 'sets available fields from partial responses' do
      representative_two.update_from_geocodio(minimal_official)
      expect(representative_two.party).to eq('Independent')
    end

    it 'leaves missing contact fields blank' do
      representative_two.update_from_geocodio(minimal_official)
      expect(representative_two.address).to be_nil
    end

    it 'leaves missing social fields blank' do
      representative_two.update_from_geocodio(minimal_official)
      expect(representative_two.twitter).to be_nil
    end

    it 'leaves missing reference fields blank' do
      representative_two.update_from_geocodio(minimal_official)
      expect(representative_two.bioguide_id).to be_nil
    end
  end

  describe '#display_photo_url' do
    it 'returns photo_url when present' do
      rep = described_class.new(photo_url: 'https://example.com/photo.jpg', bioguide_id: 'D000896')
      expect(rep.display_photo_url).to eq('https://example.com/photo.jpg')
    end

    it 'falls back to a constructed URL from bioguide_id when photo_url is missing' do
      rep = described_class.new(photo_url: nil, bioguide_id: 'D000896')
      expect(rep.display_photo_url).to eq('https://theunitedstates.io/images/congress/450x550/D000896.jpg')
    end

    it 'returns nil when both photo_url and bioguide_id are missing' do
      rep = described_class.new(photo_url: nil, bioguide_id: nil)
      expect(rep.display_photo_url).to be_nil
    end
  end

  # integration test using webmock
  describe '.geocodio_search and .civic_api_to_representative_params' do
    let(:fixture) do
      {
        'results' => [
          {
            'response' => {
              'results' => [
                {
                  'fields' => {
                    'congressional_districts' => [
                      {
                        'current_legislators' => [
                          full_official_two
                        ]
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }.to_json
    end
    let(:response) { described_class.geocodio_search('Berkeley, CA') }
    let(:representatives) { described_class.civic_api_to_representative_params(response) }
    let(:representative) { representatives.first }

    let(:full_official_two) do
      {
        'name' => 'Adam Choe',
        'type' => 'representative',
        'bio' => {
          'first_name' => 'Adam',
          'last_name' => 'Choe',
          'party' => 'Democratic',
          'birthday' => '2026-07-31',
          'gender' => 'M',
          'photo_url' => 'https://www.congress.gov/img/member/example.jpg'
        },
        'contact' => {
          'url' => 'https://bleacherreport.com',
          'address' => 'Bancroft Way',
          'phone' => '101-101-1001',
          'contact_form' => nil
        },
        'social' => {
          'twitter' => 'repachoe',
          'facebook' => 'repachoe',
          'youtube' => nil
        },
        'references' => {
          'bioguide_id' => 'D000896',
          'govtrack_id' => '000896'
        }
      }
    end

    before do
      stub_request(:post, /api\.geocod\.io/)
        .to_return(status: 200, body: fixture,
                   headers: { 'Content-Type' => 'application/json' })
    end

    it 'returns one representative' do
      expect(representatives.length).to eq(1)
    end

    it 'parses the representative name' do
      expect(representative.name).to eq('Adam Choe')
    end

    it 'parses the representative party' do
      expect(representative.party).to eq('Democratic')
    end

    it 'parses the representative bioguide id' do
      expect(representative.bioguide_id).to eq('D000896')
    end

    it 'parses the representative ocdid' do
      expect(representative.ocdid).to eq('000896')
    end
  end
end
