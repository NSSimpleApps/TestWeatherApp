//
//  WeatherApiDateParser.swift
//  TestWeatherApp
//
//  Created by user on 14.05.2025.
//

import Foundation

/// Парсит дату из строки для WeatherApi.
final class WeatherApiDateParser: Sendable {
    let calendar: Calendar
    
    init(calendar: Calendar) {
        self.calendar = calendar
    }
    
    /// Дата из строки.
    func date(from str: String) -> Date? {
        var str = String.SubSequence(str)
        
        guard let year = Int(str.prefix(4)) else { return nil }
        str = str.dropFirst(4)
        
        guard str.first == "-" else { return nil }
        str = str.dropFirst(1)
        
        guard let month = Int(str.prefix(2)) else { return nil }
        str = str.dropFirst(2)
        
        guard str.first == "-" else { return nil }
        str = str.dropFirst(1)
        
        guard let day = Int(str.prefix(2)) else { return nil }
        str = str.dropFirst(2)
        
        let hour: Int
        let minute: Int
        
        if str.first == " " {
            str = str.dropFirst(1)
            
            guard let hourValue = Int(str.prefix(2)) else { return nil }
            hour = hourValue
            str = str.dropFirst(2)
            
            guard str.first == ":" else { return nil }
            str = str.dropFirst(1)
            
            guard let minuteValue = Int(str.prefix(2)) else { return nil }
            minute = minuteValue
        } else {
            hour = 0
            minute = 0
        }
        
        let dateComponents = DateComponents(calendar: self.calendar,
                                            year: year,
                                            month: month,
                                            day: day,
                                            hour: hour,
                                            minute: minute)
        return dateComponents.date
    }
}
