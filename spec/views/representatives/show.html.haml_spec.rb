# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'representatives/show', type: :view do
  it 'renders successfully for a representative with all fields present' do
    rep = Representative.create!(
      name: 'Adam Choe',
      title: 'representative',
      party: 'Democratic',
      birthday: Date.parse('2026-07-31'),
      gender: 'M',
      address: 'Bancroft Way',
      phone: '101-101-1001',
      website: 'https://bleacherreport.com',
      twitter: 'repachoe',
      facebook: 'repachoe',
      bioguide_id: 'D000896',
      ocdid: '000896'
    )
    assign(:representative, rep)

    render

    expect(rendered).to include('Adam Choe')
    expect(rendered).to include('Democratic')
  end

  it 'renders successfully for a representative with missing optional fields' do
    rep = Representative.create!(name: 'Jane Doe', ocdid: '999999')
    assign(:representative, rep)

    render

    expect(rendered).to include('Jane Doe')
    expect(rendered).to include('No photo available')
  end
end