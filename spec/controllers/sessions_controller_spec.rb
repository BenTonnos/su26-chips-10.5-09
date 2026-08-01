# frozen_string_literal: true

require 'rails_helper'

describe SessionsController do
  before do
    allow(controller).to receive(:current_user)
  end

  let(:git_user) do
    {
      'provider' => 'github',
      'uid' => '12345',
      'info' => { 'name' => 'Ben Tonnos', 'email' => 'git@example.com' }
    }
  end

  let(:google_user) do
    {
      'provider' => 'google_oauth2',
      'uid' => '12345',
      'info' => { 'name' => 'Ben Tonnos', 'email' => 'google@example.com' }
    }
  end

  describe 'POST #create' do
    it 'creates a new GitHub user' do
      request.env['omniauth.auth'] = git_user

      expect { post :create, params: { provider: 'github' } }.to change(User, :count).by(1)

      user = User.last

      expect(session[:user_id]).to eq(user.id)
      expect(response).to redirect_to(root_url)
    end

    it 'creates a new Google user' do
      request.env['omniauth.auth'] = google_user

      expect { post :create, params: { provider: 'google_oauth2' } }.to change(User, :count).by(1)

      user = User.last

      expect(session[:user_id]).to eq(user.id)
      expect(response).to redirect_to(root_url)
    end
  end
end
