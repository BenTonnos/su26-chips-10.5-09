# frozen_string_literal: true

require 'rails_helper'

describe MyNewsItemsController do
  let(:representative) { create(:representative) }

  before do
    allow(controller).to receive(:require_login!).and_return(true)
  end

  describe 'GET #new' do
    it 'creates a new news item' do
      get :new, params: { representative_id: representative.id }
      expect(assigns(:news_item)).to be_a_new(NewsItem)
    end
  end

  describe 'POST #create' do
    subject(:create_news_item) { post :create, params: request_params }

    let(:news_item_attributes) do
      {
        title: 'Climate Change',
        description: 'An article.',
        link: 'https://www.climate.com',
        issue: 'Climate Change',
        representative_id: representative.id
      }
    end

    let(:request_params) do
      {
        representative_id: representative.id,
        news_item: news_item_attributes
      }
    end

    it 'creates a news item in the database' do
      expect { create_news_item }.to change(NewsItem, :count).by(1)
    end

    it 'saves the news item attributes' do
      create_news_item
      expect(NewsItem.last).to have_attributes(news_item_attributes)
    end
  end
end
