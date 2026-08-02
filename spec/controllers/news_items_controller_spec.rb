# frozen_string_literal: true

require 'rails_helper'

describe NewsItemsController do
  let(:user) do
    User.create!(
      uid: '12345',
      provider: User.providers[:github],
      first_name: 'Ben',
      last_name: 'Tonnos',
      email: 'git@example.com'
    )
  end

  let(:representative) { create(:representative) }
  let!(:news_item) do
    NewsItem.create!(
      representative_id: representative.id,
      title: 'Test Title',
      link: 'testlink.com',
      description: 'TestDescription'
    )
  end

  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  describe 'GET #index' do
    it "assigns the representative's news items and updates the user's id" do
      get :index, params: { representative_id: representative.id }
      expect(assigns(:news_items)).to eq([news_item])
      expect(assigns(:curr_user_id)).to eq(user.id)
    end
  end
end
