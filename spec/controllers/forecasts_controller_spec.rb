require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    let(:zip_code) { '10001' }
    let(:country_code) { 'US' }
    let(:weather_data) { { 'current' => { 'temp' => 20.0 } } }

    before do
      allow(WeatherProxy).to receive(:get_weather_data).with(zip_code: zip_code, country_code: country_code).and_return(weather_data)
    end

    it 'returns a successful response' do
      get :show, params: { zip_code: zip_code, country_code: country_code }
      expect(response).to be_successful
    end
  end
end
