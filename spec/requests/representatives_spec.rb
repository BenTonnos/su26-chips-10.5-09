# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Representative profile page' do
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

    get representative_path(rep)

    expect(response).to have_http_status(:success)
    expect(response.body).to include('Adam Choe')
  end

  it 'renders successfully for a representative with missing optional fields' do
    rep = Representative.create!(name: 'Jane Doe', ocdid: '999999')
    # party, birthday, gender, address, phone, website, twitter, facebook,
    # youtube, contact_form_url, bioguide_id, photo_url all left nil

    get representative_path(rep)

    expect(response).to have_http_status(:success)
    expect(response.body).to include('Jane Doe')
    expect(response.body).to include('No photo available')
  end
end
