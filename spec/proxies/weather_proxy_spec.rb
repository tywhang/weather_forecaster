require 'rails_helper'

RSpec.describe WeatherProxy, type: :model do
  let(:zip_code) { '10001' }
  let(:country_code) { 'US' }
  let(:weather_proxy) { WeatherProxy.new }

  describe '#get_weather_data' do
    it 'returns weather data for a given zip and country code' do
      result = 
        VCR.use_cassette('get_weather_data') do
          weather_proxy.get_weather_data(zip_code: zip_code, country_code: country_code)
        end

      expect(result['current']['dt']).to be_present
      expect(result['current']['temp']).to be_present
      expect(result['daily'].length).to eq(8)

      result['daily'].each do |day|
        expect(day['dt']).to be_present
        expect(day['temp']['day']).to be_present
        expect(day['weather'].length).to eq(1)
      end
    end
  end

  describe '#get_lat_lon' do
    it 'returns latitude and longitude for a given zip code and country code' do
      result =
        VCR.use_cassette('get_lat_lon') do
          weather_proxy.send(:get_lat_lon, zip_code: zip_code, country_code: country_code)
        end

      expect(result).to eq([40.7484, -73.9967])
    end
  end
end
