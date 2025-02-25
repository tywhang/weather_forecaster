require 'rails_helper'

RSpec.describe WeatherProxy, type: :model do
  let(:zip_code) { '10001' }
  let(:country_code) { 'US' }
  let(:invalid_zip_code) { '000000' }
  let(:invalid_country_code) { 'ZZ' }

  describe '#get_weather_data' do
    context 'when the zip and country code are valid' do
      it 'returns weather data' do
        result = VCR.use_cassette('get_weather_data_valid_zip_and_country_code') do
          WeatherProxy.get_weather_data(zip_code: zip_code, country_code: country_code)
        end

        expect(result.except(:cache_exists, :daily)).to eq(
          {
            lat: 40.7484,
            lon: -73.9967,
            date: 'February 25, 2025',
            time: '05:05 PM',
            day_of_week: 'Tue',
            temp: 50
          }
        )

        expect(result[:daily].length).to eq(7)

        result[:daily].each do |day|
          expect(day[:day_of_week]).to be_present
          expect(day[:temp_min]).to be_present
          expect(day[:temp_max]).to be_present
        end

        first_result = result[:daily].first
        expect(first_result[:day_of_week]).to eq('Tue')
        expect(first_result[:temp_min]).to eq(38)
        expect(first_result[:temp_max]).to eq(51)
      end
    end

    context 'when the zip and country code are not valid' do
      it 'raises an error with the correct message' do
        expect do
          VCR.use_cassette('get_weather_data_invalid_zip_and_country_code') do
            WeatherProxy.get_weather_data(zip_code: invalid_zip_code, country_code: invalid_country_code)
          end
        end.to raise_error(RuntimeError, 'WeatherProxy - zip_code: 000000, country_code: ZZ: Failed to fetch weather data: WeatherProxy - zip_code: 000000, country_code: ZZ: HTTP request failed with code 400: Bad Request.')
      end
    end
  end

  describe '#get_lat_lon' do
    context 'when the zip and country code are valid' do
      it 'returns the latitude and longitude' do
        result = VCR.use_cassette('get_lat_lon_valid_zip_and_country_code') do
          WeatherProxy.send(:get_lat_lon, zip_code: zip_code, country_code: country_code)
        end

        expect(result).to eq([40.7484, -73.9967])
      end
    end

    context 'when the zip and country code are not valid' do
      it 'return nil values' do
        result = VCR.use_cassette('get_lat_lon_invalid_zip_and_country_code') do
          WeatherProxy.send(:get_lat_lon, zip_code: invalid_zip_code, country_code: invalid_country_code)
        end

        expect(result).to eq([nil, nil])
      end
    end
  end
end
