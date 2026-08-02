# frozen_string_literal: true

require 'rails_helper'

describe MyEventsController do
  before do
    allow(controller).to receive(:require_login!).and_return(true)
  end

  describe 'GET #new' do
    it 'creates a new event' do
      get :new
      expect(assigns(:event)).to be_a_new(Event)
    end
  end
end
