# frozen_string_literal: true

require 'rails_helper'

describe SearchController do
  describe 'GET #search' do
    let(:test_results) do
      {
        'results' => []
      }
    end

    before do
      allow(Representative).to receive(:geocodio_search)
        .with('string')
        .and_return(test_results)

      allow(Representative).to receive(:civic_api_to_representative_params)
        .with(test_results)
        .and_return([])
    end

    it 'searches for representatives and renders the search page' do
      get :search, params: { address: 'string' }
      expect(Representative).to have_received(:geocodio_search).with('string')
      expect(assigns(:search_term)).to eq('string')
      expect(assigns(:representatives)).to eq([])
      expect(response).to render_template('representatives/search')
    end
  end
end
