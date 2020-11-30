//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by Александр Камышев on 15.11.2020.
//

import WidgetKit
import SwiftUI
import DataLayer
import Domain

struct Provider: TimelineProvider {
    
    lazy var useCase = DataLayer.UseCaseProvider().makeWeatherDataUseCase()
    
    func placeholder(in context: Context) -> SimpleEntry {
        print("placeholder")
        return SimpleEntry.emptyObjectWith(date: Date(), id: 0, cityName: "Belgium")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        print("getSnapshot")
        let entry = SimpleEntry.emptyObjectWith(date: Date(), id: 0, cityName: "Belgium")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        print("getTimeline")
        DataLayer.UseCaseProvider().makeWeatherDataUseCase().localStorageWeather { (result) in
            let date = Date()
            let nextUpdateDate = Calendar.current.date(byAdding: .second, value: 15, to: date)!
            var timeline: Timeline<SimpleEntry>
            switch result {
            case .success(let data):
                let widgetData = data
                    .filter { $0.isFavorited }
                    .map { $0.asSimpleWeatherData() }
                let entry = SimpleEntry(date: date, weatherData: widgetData)
                timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            case .failure(let error):
                var errorDescription: String
                switch error {
                case .localStorageIsEmpty:
                    errorDescription = "Add new city in the app"
                default:
                    errorDescription = error.localizedDescription
                }
                //use local weather data or placeholder (or show warning about network connection)
                let simpleEntry = SimpleEntry(errorDescription: errorDescription)
                timeline = Timeline<SimpleEntry>(entries: [simpleEntry], policy: .after(nextUpdateDate))
            }
            completion(timeline)
        }
    }
}

class SimpleWeatherData {
    private let weatherData: Domain.WeatherData
    
    var cityName: String {
        return weatherData.name
    }
    
    var updateDateTime: String {
        let date = Date(timeIntervalSince1970: TimeInterval(weatherData.dt))
        let dateFormatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            dateFormatter.dateFormat = "h:mm a"
        } else {
            dateFormatter.dateFormat = "MMM d, h:mm a"
        }
        return dateFormatter.string(from: date)
    }
    
    var currentTemp: String {
        return "\(weatherData.main.temp.rounded())°"
    }
    
    var minTemp: String {
        return "\(weatherData.main.tempMin.rounded())°"
    }
    
    var maxTemp: String {
        return "\(weatherData.main.tempMax.rounded())°"
    }
    
    init(weatherData: Domain.WeatherData) {
        self.weatherData = weatherData
    }
}

extension SimpleWeatherData: Identifiable { }

struct SimpleEntry: TimelineEntry {
    let date: Date
    var errorDescription: String? = nil
    let weatherData: [SimpleWeatherData]
    
    init(date: Date, weatherData: [SimpleWeatherData]) {
        self.date = date
        self.weatherData = weatherData
    }
    
    init(errorDescription: String) {
        self.init(date: Date(), weatherData: [])
        self.errorDescription = errorDescription
    }
    
    public static func emptyObjectWith(date: Date, id: Int, cityName: String, dt: Int = 0) -> Self {
        let weatherData = WeatherData.init(isFavorited: false, weather: [], main: .init(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), cod: 0, sys: .init(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), coord: .init(lon: 0, lat: 0), base: "", visibility: 0, wind: .init(speed: 0, deg: 0), clouds: .init(all: 0), dt: dt, timezone: 0, id: id, name: cityName).asSimpleWeatherData()
        return SimpleEntry(date: date, weatherData: [weatherData])
    }
    
}

extension WeatherData {
    func asSimpleWeatherData() -> SimpleWeatherData {
        return SimpleWeatherData(weatherData: self)
    }
}

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry
    
    var weatherData: SimpleWeatherData? {
        return entry.weatherData.first
    }

    @ViewBuilder
    var body: some View {
        if let weatherData = weatherData {
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(weatherData.cityName)")
                        .font(.title)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    Text("\(weatherData.currentTemp)").frame(maxWidth: .infinity, alignment: .leading).font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("H:\(weatherData.maxTemp) L:\(weatherData.minTemp)")
                        .minimumScaleFactor(0.5)
                        .font(.body)
                        .lineLimit(1)
                    Text("Updated: \(weatherData.updateDateTime)").font(.caption2)
                }
            }.padding(.all)
        } else {
            Text("Set favorited city in the app")
        }
    }
}

@main
struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Weather")
        .description("See the current weather in a favorited city.")
    }
}

struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherWidgetEntryView(entry: SimpleEntry.emptyObjectWith(date: Date(), id: 0, cityName: "BelgiumTestTestTestTestTest"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
