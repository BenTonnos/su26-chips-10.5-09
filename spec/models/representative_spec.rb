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

      official = {
         'name' => 'Francisco De La Riega',
         'party' => 'Democratic',
         'photo_url' => 'https://myimage.com/'
        }

      Representative.find_rep(official, title: 'Representative', ocdid: '12345')
      Representative.find_rep(official, title: 'Representative', ocdid: '12345')
      expect(Representative.count).to eq(1)
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

    it 'populates all fields from a full Geocodio response' do
      rep = Representative.new
      rep.update_from_geocodio(full_official)

      expect(rep.party).to eq('Democratic')
      expect(rep.birthday).to eq(Date.parse('2026-07-31'))
      expect(rep.gender).to eq('M')
      expect(rep.address).to eq('Bancroft Way')
      expect(rep.phone).to eq('101-101-1001')
      expect(rep.website).to eq('https://bleacherreport.com')
      expect(rep.contact_form_url).to be_nil
      expect(rep.twitter).to eq('repachoe')
      expect(rep.facebook).to eq('repachoe')
      expect(rep.youtube).to be_nil
      expect(rep.bioguide_id).to eq('D000896')
      expect(rep.ocdid).to eq('000896')
    end

    it 'gracefully handles a response missing entire blocks (contact, social, references)' do
      minimal_official = {
        'name' => 'Jane Doe',
        'type' => 'senator',
        'bio' => {
          'first_name' => 'Jane',
          'last_name' => 'Doe',
          'party' => 'Independent'
        }
      }

      rep = Representative.new
      expect { rep.update_from_geocodio(minimal_official) }.not_to raise_error

      expect(rep.party).to eq('Independent')
      expect(rep.address).to be_nil
      expect(rep.phone).to be_nil
      expect(rep.twitter).to be_nil
      expect(rep.bioguide_id).to be_nil
    end
  end

  describe '#display_photo_url' do
    it 'returns photo_url when present' do
      rep = Representative.new(photo_url: 'https://example.com/photo.jpg', bioguide_id: 'D000896')
      expect(rep.display_photo_url).to eq('https://example.com/photo.jpg')
    end

    it 'falls back to a constructed URL from bioguide_id when photo_url is missing' do
      rep = Representative.new(photo_url: nil, bioguide_id: 'D000896')
      expect(rep.display_photo_url).to eq('https://theunitedstates.io/images/congress/450x550/D000896.jpg')
    end

    it 'returns nil when both photo_url and bioguide_id are missing' do
      rep = Representative.new(photo_url: nil, bioguide_id: nil)
      expect(rep.display_photo_url).to be_nil
    end
  end
end

# integration test using webmock
describe '.geocodio_search and .civic_api_to_representative_params' do
  it 'fetches and parses a representative from a stubbed Geocodio response' do
    fixture = {
      'results' => [
        {
          'response' => {
            'results' => [
              {
                'fields' => {
                  'congressional_districts' => [
                    {
                      'current_legislators' => [
                        {
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

    stub_request(:post, /api\.geocod\.io/)
      .to_return(status: 200, body: fixture, headers: { 'Content-Type' => 'application/json' })

    response = Representative.geocodio_search('Berkeley, CA')
    reps = Representative.civic_api_to_representative_params(response)

    expect(reps.length).to eq(1)
    rep = reps.first
    expect(rep.name).to eq('Adam Choe')
    expect(rep.party).to eq('Democratic')
    expect(rep.bioguide_id).to eq('D000896')
    expect(rep.ocdid).to eq('000896')
  end
end
