class ForecastsController < ApplicationController
  def index
  end

  def show
    location = params[:location]&.strip

    if location.blank?
      render json: { error: "Please provide a location" }, status: :bad_request
      return
    end

    weather_data = WeatherService.new.get_forecast(location)

    if weather_data[:error]
      render json: { error: weather_data[:error] }, status: :unprocessable_entity
    else
      render json: weather_data
    end
  end
end
