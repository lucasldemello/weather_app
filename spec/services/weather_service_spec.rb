require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  subject(:service) { described_class.new }

  before do
    Rails.cache.clear
  end

  describe '#get_forecast' do
    context 'with real API calls', :vcr do
      it 'returns complete weather data for Timbó' do
        result = service.get_forecast('Timbó')

        expect(result[:error]).to be_nil
        expect(result[:location]).to include('Timbó')
        expect(result[:current_temp]).to be_a(Integer)
        expect(result[:high_temp]).to be_a(Integer)
        expect(result[:low_temp]).to be_a(Integer)
        expect(result[:from_cache]).to eq(false)
        expect(result[:forecast]).to be_an(Array)
        expect(result[:forecast].length).to be <= 5
        expect(result[:feels_like]).to be_a(Integer)
        expect(result[:humidity]).to be_a(Integer)
        expect(result[:description]).to be_a(String)
      end

      it 'returns error for Brazilian postal code' do
        result = service.get_forecast('01001-000')

        expect(result[:error]).to eq("Location not found or API error")
      end

      it 'returns weather data for US ZIP code' do
        result = service.get_forecast('10001')

        expect(result[:error]).to be_nil
        expect(result[:current_temp]).to be_a(Integer)
      end

      it 'returns error for invalid location' do
        result = service.get_forecast('InvalidCity999XYZ')

        expect(result[:error]).to be_present
        expect(result[:error]).to include('Location not found')
      end
    end

    context 'with caching and time manipulation' do
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
        Timecop.freeze(Time.local(2024, 1, 15, 12, 0, 0))

        allow(service).to receive(:fetch_current_weather)
          .and_return(double(success?: true, parsed_response: mock_current_response))

        allow(service).to receive(:fetch_forecast)
          .and_return(double(success?: true, parsed_response: mock_forecast_response))
      end

      after do
        Timecop.return
      end

      it 'caches the result for exactly 30 minutes' do
        location = 'TestCity'

        # First request - should hit API
        result1 = service.get_forecast(location)
        expect(result1[:from_cache]).to eq(false)

        # Second request immediately - should come from cache
        result2 = service.get_forecast(location)
        expect(result2[:from_cache]).to eq(true)
        expect(result2[:current_temp]).to eq(result1[:current_temp])

        # Move time forward 29 minutes - should still be cached
        Timecop.travel(29.minutes.from_now)
        result3 = service.get_forecast(location)
        expect(result3[:from_cache]).to eq(true)

        # Move time forward 31 minutes total - cache should expire
        Timecop.travel(2.minutes.from_now)
        result4 = service.get_forecast(location)
        expect(result4[:from_cache]).to eq(false)
      end

      it 'uses different cache keys for different locations' do
        result_sp = service.get_forecast('Timbó')
        expect(result_sp[:from_cache]).to eq(false)

        result_rio = service.get_forecast('Rio de Janeiro')
        expect(result_rio[:from_cache]).to eq(false)

        # Second requests should be cached independently
        result_sp2 = service.get_forecast('Timbó')
        expect(result_sp2[:from_cache]).to eq(true)

        result_rio2 = service.get_forecast('Rio de Janeiro')
        expect(result_rio2[:from_cache]).to eq(true)
      end
    end

    # Testes de erro com mocks
    context 'when API fails' do
      before do
        allow(service).to receive(:fetch_current_weather).and_raise(StandardError, "Network timeout")
      end

      it 'handles API errors gracefully' do
        result = service.get_forecast('Timbó')

        expect(result[:error]).to be_present
        expect(result[:error]).to include('Unable to fetch weather data')
      end
    end
  end

  describe 'private methods' do
    let(:mock_current_response) do
      {
        'name' => 'Timbó',
        'sys' => { 'country' => 'BR' },
        'main' => {
          'temp' => 25.7,
          'feels_like' => 27.2,
          'humidity' => 65
        },
        'weather' => [ {
          'description' => 'clear sky',
          'icon' => '01d'
        } ],
        'wind' => { 'speed' => 3.5 }
      }
    end

    let(:mock_forecast_response) do
      {
        'list' => [
          {
            'dt_txt' => '2024-01-15 12:00:00',
            'main' => { 'temp' => 28.0 },
            'weather' => [ { 'description' => 'sunny', 'icon' => '01d' } ]
          },
          {
            'dt_txt' => '2024-01-15 15:00:00',
            'main' => { 'temp' => 30.5 },
            'weather' => [ { 'description' => 'sunny', 'icon' => '01d' } ]
          }
        ]
      }
    end

    describe '#parse_weather_data' do
      it 'parses weather data correctly with proper rounding' do
        result = service.send(:parse_weather_data, mock_current_response, mock_forecast_response)

        expect(result[:current_temp]).to eq(26) # 25.7 rounded
        expect(result[:high_temp]).to eq(31) # 30.5 rounded up
        expect(result[:low_temp]).to eq(28) # 28.0 rounded
        expect(result[:location]).to eq('Timbó, BR')
        expect(result[:description]).to eq('Clear sky')
        expect(result[:feels_like]).to eq(27)
        expect(result[:humidity]).to eq(65)
        expect(result[:wind_speed]).to eq(3.5)
        expect(result[:forecast]).to be_an(Array)
      end
    end
  end
end
