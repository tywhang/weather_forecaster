class WeatherProxy
  GEOCODING_BASE_API = "http://api.openweathermap.org/geo/1.0/zip"
  ONECALL_BASE_API = "https://api.openweathermap.org/data/3.0/onecall"

  class << self
    def get_weather_data(zip_code:, country_code:)
      cache_key = "weather_data/#{country_code}/#{zip_code}"
      cache_exists = Rails.cache.exist?(cache_key)
      
      res = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
        lat, lon = get_lat_lon(zip_code: zip_code, country_code: country_code)
        url = "#{ONECALL_BASE_API}?lat=#{lat}&lon=#{lon}&exclude=minutely,hourly,alerts&units=imperial&appid=#{api_key}"
        response = HTTParty.get(url)
        handle_response(response, zip_code: zip_code, country_code: country_code)
      end

      res.merge(cache_exists: cache_exists)
    rescue StandardError => e
      raise_exception("Failed to fetch weather data: #{e.message}.", zip_code:, country_code:)
    end

    private

    def get_lat_lon(zip_code:, country_code:)
      url = "#{GEOCODING_BASE_API}?zip=#{zip_code},#{country_code}&appid=#{api_key}"

      response = HTTParty.get(url)
      response_json = JSON.parse(response.body)

      lat = response_json["lat"]
      lon = response_json["lon"]

      [lat, lon]
    end

    def api_key
      @api_key = ENV['WEATHER_API_KEY']
    end

    def handle_response(response, zip_code:, country_code:)
      if response.success?
        parse_response(response.body)
      else
        raise_exception("HTTP request failed with code #{response.code}: #{response.message}", zip_code:, country_code:)
      end
    rescue JSON::ParserError => e
      raise_exception("Failed to parse JSON response: #{e.message}", zip_code:, country_code:)
    end

    def parse_response(response)
      res = JSON.parse(response)
      current_dt = res['current']['dt']

      {
        lat: res['lat'],
        lon: res['lon'],
        date: dt_to_date(current_dt),
        time: dt_to_time(current_dt),
        day_of_week: dt_to_day_of_week(current_dt),
        temp: res['current']['temp'].round,
        daily: res['daily'].slice(0, 7).map do |day|
          {
            day_of_week: dt_to_day_of_week(day['dt']),
            temp_min: day['temp']['min'].round,
            temp_max: day['temp']['max'].round,
          }
        end
      }
    end

    def dt_to_date(dt)
      Time.at(dt).strftime("%B %d, %Y")
    end

    def dt_to_time(dt)
      Time.at(dt).strftime("%I:%M %p")
    end

    def dt_to_day_of_week(dt)
      Time.at(dt).strftime("%a")
    end

    def raise_exception(message, zip_code:, country_code:)
      raise "WeatherProxy - zip_code: #{zip_code}, country_code: #{country_code}: #{message}"
    end
  end
end
