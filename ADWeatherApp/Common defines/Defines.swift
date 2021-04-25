//
//  Defines.swift
//  ADWeatherApp
//
//  Created by VIPadm on 24/04/21.
//

import Foundation
import CoreLocation


let dateformater = DateFormatter()

var isMetricType: Bool = false

let distanceSpain: CLLocationDistance = 40000

var apiKey = "eeac080fbe153725eb3be48731f2dc27"

struct WeatherAPI {
    static let ForecastApi = "https://api.openweathermap.org/data/2.5/forecast"
    //http://api.openweathermap.org/data/2.5/forecast?q=Hyderabad&appid=fae7190d7e6433ec3a45285ffcf55c86&units=metric
}


