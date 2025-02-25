class ForecastsController < ApplicationController
  def new
  end

  def show
    @zip_code = params[:zip_code]
    @country_code = params[:country_code]

    @weather_data = WeatherProxy.get_weather_data(zip_code: @zip_code, country_code: @country_code)
  end
end
