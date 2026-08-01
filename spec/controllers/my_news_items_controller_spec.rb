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
end
