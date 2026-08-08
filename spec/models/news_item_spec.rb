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
require 'rails_helper'

RSpec.describe NewsItem do
  let(:expected_issues) do
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

  describe '.issues' do
    it 'returns the article issues' do
      expect(described_class.issues).to match_array(expected_issues)
    end
  end

  describe '.currents_api_search' do
    let(:fixture) do
      articles = Array.new(6) do |i|
        {
          'title' => "Article #{i}",
          'url' => "https://example.com/#{i}",
          'description' => "Desc #{i}"
        }
      end
      { 'news' => articles }.to_json
    end

    it 'returns the top 5 articles from the API' do
      stub_request(:get, /api\.currentsapi\.services/).to_return(status: 200, body: fixture)
      articles = described_class.currents_api_search('Immigration')
      expect(articles.length).to eq(5)
      expect(articles.first).to eq(title: 'Article 0', link: 'https://example.com/0', description: 'Desc 0')
    end

    it 'returns an empty array when the API call fails' do
      stub_request(:get, /api\.currentsapi\.services/).to_return(status: 500, body: '')
      expect(described_class.currents_api_search('Immigration')).to eq([])
    end
  end
  
  describe 'creating from a selected article' do
    let(:representative) { Representative.create!(name: 'Test Rep', ocdid: '1') }
    let(:article) { { title: 'Test Title', link: 'https://example.com', description: 'Test Desc' } }

    it 'builds and saves a valid news item from selected article data' do
      news_item = described_class.new(article.merge(issue: 'Immigration', representative_id: representative.id))
      expect(news_item.save).to be true

    end
  end
end
