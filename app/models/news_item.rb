# frozen_string_literal: true

# == Schema Information
#
# Table name: news_items
#
#  id                :integer          not null, primary key
#  description       :text
#  issue             :string
#  link              :string           not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  representative_id :integer          not null
#
# Indexes
#
#  index_news_items_on_representative_id  (representative_id)
#
class NewsItem < ApplicationRecord
  # TODO: this belongs to a user (creator_id)
  belongs_to :representative

  def self.find_for(representative_id)
    NewsItem.find_by(
      representative_id: representative_id
    )
  end

  def self.issues
    [
      'Free Speech',
      'Immigration',
      'Terrorism',
      'Social Security and Medicare',
      'Abortion',
      'Student Loans',
      'Gun Control',
      'Unemployment',
      'Climate Change',
      'Homelessness',
      'Racism',
      'Tax Reform',
      'Net Neutrality',
      'Religious Freedom',
      'Border Security',
      'Minimum Wage',
      'Equal Pay'
    ]
  end

  def self.currents_api_search(issue)
    currents_api_key = ENV.fetch('CURRENTS_API_KEY', Rails.application.credentials[:CURRENTS_API_KEY])
    raise ArgumentError, 'Missing CURRENTS_API_KEY' if currents_api_key.blank?

    response = Faraday.get('https://api.currentsapi.services/v1/search') do |req|
      req.params['keywords'] = issue
      req.params['apiKey'] = currents_api_key
      req.params['language'] = 'en'
    end

    return [] unless response.success?

    data = JSON.parse(response.body)
    news = data['news'] || []

    news.first(5).map do |article|
      {
        title: article['title'],
        link: article['url'],
        description: article['description']
      }
    end
  end
end
