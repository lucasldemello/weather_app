import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "locationInput",
    "submitButton",
    "submitText",
    "loadingText",
    "loading",
    "error",
    "errorMessage",
    "results",
    "location",
    "currentTemp",
    "feelsLike",
    "description",
    "highTemp",
    "lowTemp",
    "humidity",
    "cacheIndicator",
    "forecast",
  ];

  connect() {
    console.log("Weather controller connected! 🌤️");
  }

  search(event) {
    event.preventDefault();

    const location = this.locationInputTarget.value.trim();
    if (!location) {
      this.showError("Please enter a location");
      return;
    }

    this.showLoading();
    this.fetchWeather(location);
  }

  async fetchWeather(location) {
    try {
      const response = await fetch(`/weather/${encodeURIComponent(location)}`, {
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')
            .content,
        },
      });

      const data = await response.json();

      if (response.ok) {
        this.displayWeather(data);
      } else {
        this.showError(data.error || "Unable to fetch weather data");
      }
    } catch (error) {
      console.error("Fetch error:", error);
      this.showError("Connection error. Please try again.");
    }
  }

  displayWeather(data) {
    this.hideAllStates();

    this.locationTarget.textContent = data.location;
    this.currentTempTarget.textContent = `${data.current_temp}°C`;
    this.feelsLikeTarget.textContent = `Feels like: ${data.feels_like}°C`;
    this.descriptionTarget.textContent = data.description;
    this.highTempTarget.textContent = `${data.high_temp}°C`;
    this.lowTempTarget.textContent = `${data.low_temp}°C`;
    this.humidityTarget.textContent = `${data.humidity}%`;

    this.updateCacheIndicator(data.from_cache);
    this.displayForecast(data.forecast);

    this.resultsTarget.classList.remove("hidden");
    this.resultsTarget.classList.add("fade-in");
    this.resultsTarget.scrollIntoView({ behavior: "smooth" });
  }

  displayForecast(forecast) {
    this.forecastTarget.innerHTML = "";

    forecast.forEach((day) => {
      const forecastCard = this.createForecastCard(day);
      this.forecastTarget.appendChild(forecastCard);
    });
  }

  createForecastCard(day) {
    const card = document.createElement("div");
    card.className =
      "text-center p-4 bg-gradient-to-br from-blue-50 to-white rounded-xl border border-blue-100 hover:shadow-lg transition-shadow";

    card.innerHTML = `
      <div class="text-sm font-medium text-gray-600 mb-2">${day.day_name}</div>
      <div class="text-lg font-bold text-gray-800 mb-1">${day.date}</div>
      <div class="text-2xl mb-2">${this.getWeatherIcon(day.icon)}</div>
      <div class="text-xs text-gray-600 mb-2">${day.description}</div>
      <div class="flex justify-between text-sm">
        <span class="text-red-600 font-semibold">${day.high}°</span>
        <span class="text-blue-600">${day.low}°</span>
      </div>
    `;

    return card;
  }

  updateCacheIndicator(fromCache) {
    const indicator = this.cacheIndicatorTarget;
    const dot = indicator.querySelector(".w-2");
    const text = indicator.querySelector("span:last-child");

    if (fromCache) {
      indicator.className =
        "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-green-100 text-green-800";
      dot.className = "w-2 h-2 rounded-full mr-2 bg-green-500";
      text.textContent = "💾 From cache";
    } else {
      indicator.className =
        "inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-blue-100 text-blue-800";
      dot.className = "w-2 h-2 rounded-full mr-2 bg-blue-500";
      text.textContent = "🌐 Fresh data";
    }
  }

  showLoading() {
    this.hideAllStates();
    this.loadingTarget.classList.remove("hidden");
    this.submitButtonTarget.disabled = true;
    this.submitTextTarget.classList.add("hidden");
    this.loadingTextTarget.classList.remove("hidden");
  }

  showError(message) {
    this.hideAllStates();
    this.errorMessageTarget.textContent = message;
    this.errorTarget.classList.remove("hidden");
    this.resetSubmitButton();
  }

  hideAllStates() {
    this.loadingTarget.classList.add("hidden");
    this.errorTarget.classList.add("hidden");
    this.resultsTarget.classList.add("hidden");
    this.resetSubmitButton();
  }

  resetSubmitButton() {
    this.submitButtonTarget.disabled = false;
    this.submitTextTarget.classList.remove("hidden");
    this.loadingTextTarget.classList.add("hidden");
  }

  getWeatherIcon(iconCode) {
    const iconMap = {
      "01d": "☀️",
      "01n": "🌙",
      "02d": "⛅",
      "02n": "☁️",
      "03d": "☁️",
      "03n": "☁️",
      "04d": "☁️",
      "04n": "☁️",
      "09d": "🌦️",
      "09n": "🌦️",
      "10d": "🌧️",
      "10n": "🌧️",
      "11d": "⛈️",
      "11n": "⛈️",
      "13d": "🌨️",
      "13n": "🌨️",
      "50d": "🌫️",
      "50n": "🌫️",
    };
    return iconMap[iconCode] || "🌤️";
  }
}
