class WeatherProxy
  GEOCODING_BASE_API = "http://api.openweathermap.org/geo/1.0/zip"
  ONECALL_BASE_API = "https://api.openweathermap.org/data/3.0/onecall"

  def initialize
    @api_key = ENV['WEATHER_API_KEY']
  end

  def get_weather_data(zip_code:, country_code:)
    lat, lon = get_lat_lon(zip_code: zip_code, country_code: country_code)

    url = "#{ONECALL_BASE_API}?lat=#{lat}&lon=#{lon}&exclude=minutely,hourly,alerts&appid=#{@api_key}"
    response = HTTParty.get(url)
    JSON.parse(response.body)
  end

  private

  def get_lat_lon(zip_code:, country_code:)
    url = "#{GEOCODING_BASE_API}?zip=#{zip_code},#{country_code}&appid=#{@api_key}"

    response = HTTParty.get(url)
    response_json = JSON.parse(response.body)

    lat = response_json["lat"]
    lon = response_json["lon"]

    [lat, lon]
  end
end
