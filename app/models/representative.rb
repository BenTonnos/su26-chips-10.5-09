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
class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  # Review the Geocodio docs
  # https://www.geocod.io/docs/#congressional-districts
  def self.geocodio_search(query)
    geocodio_api_key = ENV.fetch('GEOCODIO_API_KEY', Rails.application.credentials[:GEOCODIO_API_KEY])
    raise ArgumentError, 'Missing GEOCODIO_API_KEY' if geocodio_api_key.blank?

    geocodio = Geocodio::Gem.new(geocodio_api_key)
    geocodio.geocode(query, ['cd'])
  end

  # NOTE: This info only grabs data for the most likely represenative district
  # given a search. It would be good to adapt this to show all possible
  # matching representatives for a search / county.
  # See https://www.geocod.io/docs/#data-appends-fields
  def self.civic_api_to_representative_params(rep_info)
    reps = []
    response = rep_info['results'][0]['response']
    fields = response['results'][0]['fields']
    @legislators = fields['congressional_districts'][0]['current_legislators']

    @legislators.each_with_index do |official, _index|
      official['name'] = "#{official.dig('bio', 'first_name')} #{official.dig('bio', 'last_name')}"
      title = official['type']
      ocdid = official.dig('references', 'govtrack_id')
      reps << Representative.find_rep(official, ocdid: ocdid, title: title)
    end
    reps
  end

  def self.find_rep(official, title: '', ocdid: '')
    rep = Representative.find_by(ocdid: ocdid)
    rep ||= Representative.new(ocdid: ocdid)
    rep.update_from_geocodio(official.merge('type' => title))
    rep
  end

  def update_from_geocodio(official)
    assign_attributes(geocodio_attributes(official))
    save!
    self
  end

  def geocodio_attributes(official)
    basic_attributes(official)
      .merge(contact_attributes(official))
      .merge(social_attributes(official))
      .merge(reference_attributes(official))
  end

  def basic_attributes(official)
    {
      name: official['name'] || name,
      title: official['type'],
      party: official.dig('bio', 'party'),
      birthday: official.dig('bio', 'birthday'),
      gender: official.dig('bio', 'gender'),
      photo_url: official.dig('bio', 'photo_url')
    }
  end

  def contact_attributes(official)
    {
      address: official.dig('contact', 'address'),
      phone: official.dig('contact', 'phone'),
      contact_form_url: official.dig('contact', 'contact_form'),
      website: official.dig('contact', 'url')
    }
  end

  def social_attributes(official)
    {
      twitter: official.dig('social', 'twitter'),
      facebook: official.dig('social', 'facebook'),
      youtube: official.dig('social', 'youtube')
    }
  end

  def reference_attributes(official)
    {
      ocdid: official.dig('references', 'govtrack_id') || ocdid,
      bioguide_id: official.dig('references', 'bioguide_id')
    }
  end

  def display_photo_url
    photo_url.presence || (if bioguide_id.present?
                             "https://theunitedstates.io/images/congress/450x550/#{bioguide_id}.jpg"
                           end)
  end
end
