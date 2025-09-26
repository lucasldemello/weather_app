class WeatherService
  include HTTParty
  base_uri "https://api.openweathermap.org/data/2.5"

  def initialize
    @api_key = Rails.application.credentials.openweather_api_key

    if Rails.env.development?
      if @api_key
        Rails.logger.info "🔑 Using API key from Rails credentials"
        Rails.logger.info "🔑 API Key (masked): #{@api_key[0..8]}..."
      else
        Rails.logger.error "❌ No API key found in Rails credentials!"
        Rails.logger.error "   Run: rails credentials:edit"
        Rails.logger.error "   Add: openweather_api_key: YOUR_KEY_HERE"
      end
    end
  end

  def get_forecast(location)
    return { error: "API key not configured" } unless @api_key

    cache_key = "weather_#{location.to_s.strip.downcase}"
    cached_data = Rails.cache.read(cache_key)

    if cached_data
      cached_data[:from_cache] = true
      return cached_data
    end

    begin
      response = fetch_current_weather(location)
      forecast_response = fetch_forecast(location)

      if response.success? && forecast_response.success?
        weather_data = parse_weather_data(response.parsed_response, forecast_response.parsed_response)
        weather_data[:from_cache] = false

        Rails.cache.write(cache_key, weather_data, expires_in: 30.minutes)
        weather_data
      else
        log_api_error(response, location)
        { error: "Location not found or API error" }
      end
    rescue => e
      Rails.logger.error "Weather API Error: #{e.message}"
      { error: "Unable to fetch weather data" }
    end
  end

  private

  def log_api_error(response, location)
    if Rails.env.development?
      Rails.logger.error "❌ Weather API failed for location: #{location}"
      Rails.logger.error "   Status: #{response.code}"
      Rails.logger.error "   Body: #{response.body}"

      if brazilian_postal_code?(location)
        Rails.logger.warn "💡 Note: Testing Brazilian postal code format"
        Rails.logger.warn "   If this fails, try city name instead: 'Blumenau' or 'São Paulo'"
      end
    end
  end

  def fetch_current_weather(location)
    query = build_query(location)

    params = {
      q: query,
      appid: @api_key,
      units: "metric",
      lang: "en"
    }

    if Rails.env.development?
      Rails.logger.info "🌤️  Fetching weather for: #{location} → query: #{query}"
    end

    self.class.get("/weather", { query: params })
  end

  def fetch_forecast(location)
    query = build_query(location)

    self.class.get("/forecast", {
      query: {
        q: query,
        appid: @api_key,
        units: "metric",
        lang: "en",
        cnt: 16
      }
    })
  end

  def build_query(location)
    if brazilian_postal_code?(location)
      # Brazilian postal code with country
      "#{location},BR"
    elsif us_zip_code?(location)
      # US ZIP code (API detects country automatically)
      location
    else
      # City name or other format
      location
    end
  end

  def brazilian_postal_code?(location)
    # Brazilian CEP: 12345-678 or 12345678
    location.to_s.match?(/^\d{5}-?\d{3}$/)
  end

  def us_zip_code?(location)
    # US ZIP: 12345 or 12345-6789
    location.to_s.match?(/^\d{5}(-\d{4})?$/)
  end

  def parse_weather_data(current, forecast)
    {
      current_temp: current["main"]["temp"].round,
      high_temp: forecast["list"].first(8).map { |f| f["main"]["temp"] }.max.round,
      low_temp: forecast["list"].first(8).map { |f| f["main"]["temp"] }.min.round,
      forecast: build_daily_forecast(forecast),
      location: "#{current['name']}, #{current['sys']['country']}",
      description: current["weather"][0]["description"].capitalize,
      feels_like: current["main"]["feels_like"].round,
      humidity: current["main"]["humidity"],
      wind_speed: current["wind"]["speed"]&.round(1),
      icon: current["weather"][0]["icon"]
    }
  end

  def build_daily_forecast(forecast)
    daily_forecast = []
    forecast["list"].group_by { |item| Date.parse(item["dt_txt"]).strftime("%Y-%m-%d") }.each do |date, items|
      temps = items.map { |item| item["main"]["temp"] }
      daily_forecast << {
        date: Date.parse(date).strftime("%d/%m"),
        day_name: Date.parse(date).strftime("%a"),
        high: temps.max.round,
        low: temps.min.round,
        description: items[0]["weather"][0]["description"].capitalize,
        icon: items[0]["weather"][0]["icon"]
      }
      break if daily_forecast.length >= 5
    end
    daily_forecast
  end
end
