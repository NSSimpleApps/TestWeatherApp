```
git clone https://github.com/NSSimpleApps/TestWeatherApp.git
cd TestWeatherApp
pod install
open TestWeatherApp.xcworkspace
```

Если приложение будет получать ошибку от `api.weather.com` из-за неправильного ключа,
то обновить ключ, который находится в константе `WEATHER_API_KEY`.

Также добавлена погода от api.openweathermap.org. Ключ находится в константе `OPEN_WEATHERMAP_APPID`.
