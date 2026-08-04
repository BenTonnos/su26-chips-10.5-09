# frozen_string_literal: true

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
end
