require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    let(:weather_service) { instance_double(WeatherService) }

    before do
      allow(WeatherService).to receive(:new).and_return(weather_service)
    end

    context 'with valid location' do
      let(:weather_data) do
        {
          location: 'Indaial, BR',
          current_temp: 25,
          high_temp: 28,
          low_temp: 18,
          feels_like: 27,
          description: 'Clear sky',
          humidity: 65,
          from_cache: false,
          forecast: [
            {
              date: '15/01',
              day_name: 'Mon',
              high: 28,
              low: 18,
              description: 'Sunny',
              icon: '01d'
            }
          ]
        }
      end

      it 'returns complete weather data as JSON' do
  allow(weather_service).to receive(:get_forecast).with('Indaial').and_return(weather_data)

  get :show, params: { location: 'Indaial' }

        expect(response).to be_successful
        expect(response.content_type).to eq('application/json; charset=utf-8')

        json_response = JSON.parse(response.body)
  expect(json_response['location']).to eq('Indaial, BR')
        expect(json_response['current_temp']).to eq(25)
        expect(json_response['high_temp']).to eq(28)
        expect(json_response['low_temp']).to eq(18)
        expect(json_response['from_cache']).to eq(false)
        expect(json_response['forecast']).to be_an(Array)
      end

      it 'handles cached responses correctly' do
        cached_data = weather_data.merge(from_cache: true)
  allow(weather_service).to receive(:get_forecast).with('Indaial').and_return(cached_data)

  get :show, params: { location: 'Indaial' }

        json_response = JSON.parse(response.body)
        expect(json_response['from_cache']).to eq(true)
      end
    end

    context 'with invalid location' do
      it 'returns error when location is blank' do
        get :show, params: { location: '' }

        expect(response).to have_http_status(:bad_request)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Please provide a location')
      end

      it 'returns error when weather service fails' do
        allow(weather_service).to receive(:get_forecast).and_return({ error: 'Location not found' })

        get :show, params: { location: 'InvalidCity' }

        # Use new status code to avoid deprecation warning
        expect(response).to have_http_status(:unprocessable_content)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Location not found')
      end
    end
  end
end
