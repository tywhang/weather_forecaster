class WeatherProxy
  GEOCODING_BASE_API = "http://api.openweathermap.org/geo/1.0/zip"
  ONECALL_BASE_API = "https://api.openweathermap.org/data/3.0/onecall"

  class << self
    def get_weather_data(zip_code:, country_code:)
      lat, lon = get_lat_lon(zip_code: zip_code, country_code: country_code)

      url = "#{ONECALL_BASE_API}?lat=#{lat}&lon=#{lon}&exclude=minutely,hourly,alerts&appid=#{api_key}"
      response = HTTParty.get(url)
      handle_response(response, zip_code: zip_code, country_code: country_code)
    rescue StandardError => e
      raise_exception("Failed to fetch weather data: #{e.message}.", zip_code:, country_code:)
    end

    private

    def get_lat_lon(zip_code:, country_code:)
      url = "#{GEOCODING_BASE_API}?zip=#{zip_code},#{country_code}&appid=#{api_key}"

      response = HTTParty.get(url)
      response_json = handle_response(response, zip_code: zip_code, country_code: country_code)

      lat = response_json["lat"]
      lon = response_json["lon"]

      [lat, lon]
    end

    def api_key
      @api_key = ENV['WEATHER_API_KEY']
    end

    def handle_response(response, zip_code:, country_code:)
      if response.success?
        JSON.parse(response.body)
      else
        raise_exception("HTTP request failed with code #{response.code}: #{response.message}", zip_code:, country_code:)
      end
    rescue JSON::ParserError => e
      raise_exception("Failed to parse JSON response: #{e.message}", zip_code:, country_code:)
    end

    def raise_exception(message, zip_code:, country_code:)
      raise "WeatherProxy - zip_code: #{zip_code}, country_code: #{country_code}: #{message}"
    end
  end
end
