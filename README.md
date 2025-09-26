## Requirements & Analysis

### Project Requirements

- **Ruby on Rails:** The project is built using Ruby on Rails.
- **Accept an address as input:** Users can enter a city name, postal code, or ZIP code in the search form.
- **Retrieve forecast data for the given zip code:** The app fetches weather data for any valid location, including zip codes, using the OpenWeather API.
- **Current temperature (Bonus: high/low, extended forecast):** The app displays the current temperature, high/low, and a 5-day extended forecast with daily details.
- **Display forecast details to the user:** All requested forecast details are shown in the UI.
- **Cache forecast details for 30 minutes by zip code:** The app caches forecast results for 30 minutes per location (including zip codes) using Rails.cache.
- **Display indicator if result is from cache:** The UI and API responses include a `from_cache` indicator to show when data is served from cache.

### Assumptions

- The project prioritizes functionality over form, but includes a modern UI for usability.
- The code is open to interpretation and can be extended as needed.

### Analysis

This project fully meets all specified requirements:

- Built in Ruby on Rails.
- Accepts addresses (city, postal code, ZIP code) as input.
- Retrieves and displays current temperature, high/low, and extended forecast.
- Caches results for 30 minutes by location, including zip codes.
- Shows a cache indicator to the user.

If you have additional requirements or want to further customize the app, contributions and suggestions are welcome!

# Weather Forecast App

A Ruby on Rails application that provides weather forecasts for any location using the OpenWeather API. Users can search by city name, postal code, or ZIP code and view current conditions and a 5-day forecast.

## Features

- Search weather by city, postal code, or ZIP code
- Displays current temperature, high/low, humidity, wind speed, and weather description
- 5-day forecast with daily high/low and weather icons
- Caching for faster repeated queries
- Responsive and modern UI

## Setup

1. **Clone the repository:**
   ```sh
   git clone https://github.com/lucasldemello/weather_app.git
   cd weather_app
   ```
2. **Install dependencies:**
   ```sh
   bundle install
   ```
3. **Set up the database:**
   ```sh
   rails db:setup
   ```
4. **Configure OpenWeather API key:**

   - Add your API key to `config/credentials.yml.enc` or set `OPENWEATHER_API_KEY` in your environment.

5. **Run the app:**
   ```sh
   rails server
   ```
   Visit [http://localhost:3000](http://localhost:3000)

## Running Tests

```sh
bundle exec rspec
```

## VCR Usage

- VCR is used to record and replay HTTP requests for tests.
- To refresh cassettes, delete files in `spec/vcr_cassettes/` and re-run tests.

## Folder Structure

- `app/` - Main application code
- `spec/` - RSpec tests and VCR cassettes
- `config/` - Rails and API configuration

## Contributing

Pull requests are welcome! For major changes, please open an issue first.

## License

MIT
