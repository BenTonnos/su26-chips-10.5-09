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

  describe 'creating from a selected article' do
    let(:representative) { Representative.create!(name: 'Test Rep', ocdid: '1') }
    let(:article) { { title: 'Test Title', link: 'https://example.com', description: 'Test Desc' } }

    it 'builds and saves a valid news item from selected article data' do
      news_item = described_class.new(article.merge(issue: 'Immigration', representative_id: representative.id))
      expect(news_item.save).to be true
    end
  end
end
