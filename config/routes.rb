Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Weather app routes
  root "forecasts#index"
  get "weather/:location", to: "forecasts#show", as: "weather_forecast"
end
