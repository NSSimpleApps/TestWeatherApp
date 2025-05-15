//
//  Calendar+Extensions.swift
//  TestWeatherApp
//
//  Created by user on 15.05.2025.
//

import Foundation


extension Calendar {
    /// Стандартизация дней недели, понедельник - первый.
    func standardizeWeekDaySymbols(symbols: (Calendar) -> [String]) -> [String] {
        var weekdaySymbols = symbols(self)
        let sunday = weekdaySymbols.remove(at: 0)
        weekdaySymbols.append(sunday)
        
        return weekdaySymbols
    }
    /// Индекс дня недели. Понедельник = 0, воскресенье = 6.
    func weekDayIndex(date: Date) -> Int {
        let weekdayValue = self.component(.weekday, from: date)
        let weekdayIndex: Int
        if weekdayValue == 1 {
            weekdayIndex = 6
        } else {
            weekdayIndex = weekdayValue - 2
        }
        return weekdayIndex
    }
}
