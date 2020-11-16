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
                let entry = SimpleEntry(date: date, weatherData: data)
                timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
            case .failure(let error):
                //use local weather data or placeholder (or show warning about network connection)
                timeline = Timeline<SimpleEntry>(entries: [SimpleEntry.emptyObjectWith(date: Date(), id: 1, cityName: error.localizedDescription)], policy: .after(nextUpdateDate))
            }
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let weatherData: [Domain.WeatherData]
    
    public static func emptyObjectWith(date: Date, id: Int, cityName: String, dt: Int = 0) -> Self {
        return SimpleEntry(date: date, weatherData: [.init(weather: [], main: .init(temp: 0, feelsLike: 0, tempMin: 0, tempMax: 0, pressure: 0, humidity: 0), cod: 0, sys: .init(type: 0, id: 0, country: "", sunrise: 0, sunset: 0), coord: .init(lon: 0, lat: 0), base: "", visibility: 0, wind: .init(speed: 0, deg: 0), clouds: .init(all: 0), dt: dt, timezone: 0, id: id, name: cityName)])
    }
    
}

extension WeatherData: Identifiable { }

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            ForEach(entry.weatherData) { weatherData in
                // Add last update datetime text
                Text("\(weatherData.dt): \(weatherData.name)-\(weatherData.id): \(weatherData.main.temp)").font(.system(size: 16))
            }
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
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        WeatherWidgetEntryView(entry: SimpleEntry.emptyObjectWith(date: Date(), id: 0, cityName: "Belgium"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
