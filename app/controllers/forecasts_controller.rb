class ForecastsController < ApplicationController
  def new
  end

  def show
    errors = []

    @zip_code = params[:zip_code]
    @country_code = params[:country_code]

    errors << 'Address must have a zip code' if @zip_code.blank?
    errors << 'Address must have a country code' if @country_code.blank?
    if errors.any?
      flash[:alert] = errors.join(', ')
      redirect_to new_forecasts_path
      return
    end

    @weather_data = WeatherProxy.get_weather_data(zip_code: @zip_code, country_code: @country_code)
  rescue StandardError => e
    flash[:alert] = 'Unable to fetch weather data. Please try again later.'
    redirect_to new_forecasts_path
  end
end
