require 'rails_helper'

RSpec.describe 'Cache Integration with Time Manipulation', type: :request do
  let(:mock_current_response) do
    {
      'name' => 'Test City',
      'sys' => { 'country' => 'US' },
      'main' => { 'temp' => 25.0, 'feels_like' => 27.0, 'humidity' => 60 },
      'weather' => [ { 'description' => 'clear sky', 'icon' => '01d' } ],
      'wind' => { 'speed' => 3.5 }
    }
  end

  let(:mock_forecast_response) do
    {
      'list' => [
        {
          'dt_txt' => '2024-01-15 12:00:00',
          'main' => { 'temp' => 25.0 },
          'weather' => [ { 'description' => 'clear', 'icon' => '01d' } ]
        }
      ]
    }
  end

  before do
    Rails.cache.clear
    Timecop.freeze(Time.local(2024, 1, 15, 12, 0, 0))

    # Mock HTTParty at class level for consistent behavior
    allow(WeatherService).to receive(:get).with('/weather', any_args) do
      double(success?: true, parsed_response: mock_current_response)
    end

    allow(WeatherService).to receive(:get).with('/forecast', any_args) do
      double(success?: true, parsed_response: mock_forecast_response)
    end
  end

  after do
    Timecop.return
  end

  describe 'Cache behavior over time' do
    it 'caches data for exactly 30 minutes' do
      location = 'TestCity'

      # First request - should hit API
      get "/weather/#{location}"
      expect(response).to be_successful

      first_response = JSON.parse(response.body)
      expect(first_response['from_cache']).to eq(false)

      # Second request - should use cache
      get "/weather/#{location}"
      second_response = JSON.parse(response.body)
      expect(second_response['from_cache']).to eq(true)

      # 29 minutes later - still cached
      Timecop.travel(29.minutes.from_now)
      get "/weather/#{location}"
      third_response = JSON.parse(response.body)
      expect(third_response['from_cache']).to eq(true)

      # 31 minutes later - cache expired
      Timecop.travel(2.minutes.from_now)
      get "/weather/#{location}"
      fourth_response = JSON.parse(response.body)
      expect(fourth_response['from_cache']).to eq(false)
    end
  end
end
