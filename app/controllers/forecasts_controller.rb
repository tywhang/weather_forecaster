class ForecastsController < ApplicationController
  def new
  end

  def show
    @zip_code = params[:zip_code]
    @country_code = params[:country_code]

    @weather_data = WeatherProxy.get_weather_data(zip_code: @zip_code, country_code: @country_code)
  rescue StandardError => e
    flash[:alert] = 'Unable to fetch weather data. Please try again later.'
    redirect_to new_forecasts_path
  end
end
