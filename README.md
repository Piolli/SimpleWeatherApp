Simple Weather App
=====
Get a forecast for any location. App's using [OpenWeatherMap](https://openweathermap.org/api)

The app is written using tools:
- Swift 5
- Swift PM for modularization
- UIKit
- Alamofire
- Mocker
- Realm

## Features
- Add any city to list
- Update all city's weather at one time
- Widget on the home screen for the favorite city

## Architecture
Application is divided into layers according to Clean App Architecture.
<img src="https://habrastorage.org/web/fe8/c82/a32/fe8c82a32b1548b1a297187e24ae755a.png" width="85%">

### Application Layer
It's where the user can interact with the application. All views are based on MVP-pattern.
<img src="https://upload.wikimedia.org/wikipedia/commons/d/dc/Model_View_Presenter_GUI_Design_Pattern.png" width="45%" align="center">

### Data Layer
Implementation of Domain's use cases. It's connected with Local and Server repositories.

### Local Repository and Server Repository
Implementation of Domain's Repository protocol.

### Domain
Define business-logic, entities and common protocols. It doesn't depend on UIKit or any persistence framework.

### Screens
<img src="Screenshots/add_new_city_screen.png" width="45%">
<img src="Screenshots/cities_list_screem.png" width="45%">
<img src="Screenshots/weather_details_screen.png" width="45%">
<img src="Screenshots/favorited_city.png" width="45%">
<img src="Screenshots/widget.png" width="45%">



