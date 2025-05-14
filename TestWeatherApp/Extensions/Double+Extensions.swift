//
//  Double+Extensions.swift
//  TestWeatherApp
//
//  Created by user on 14.05.2025.
//

import Foundation
import UIKit


extension Double {
    /// Форматирование дробного числа. Отбрасываются нули и точка.
    func format(precision: Int) -> String {
        let string = String(format: "%.\(precision)f", self)
        let formatted = string.reversed().drop { char in
            char == "0" || char == "."
        }.reversed()
        
        return String(formatted)
    }
}
/// Форматирование множественного числа существительных.
enum WeatherNumberCases {
    case nominative, genitive, plural
    
    func format(nominative: String, genitive: String, plural: String) -> String {
        switch self {
        case .nominative:
            return nominative
        case .genitive:
            return genitive
        case .plural:
            return plural
        }
    }
}

extension SignedInteger {
    /// Падежи существительных в зависимости от числа.
    func numberCase(locale: String) -> WeatherNumberCases {
        let abs = abs(self)
        
        if locale == "ru" {
            if abs > 10 && abs < 20 {
                return .plural
            } else {
                switch abs % 10 {
                case 1:
                    return .nominative
                case 2, 3, 4:
                    return .genitive
                default:
                    return .plural
                }
            }
        } else {
            if abs == 1 {
                return .nominative
            } else {
                return .plural
            }
        }
    }
}

extension CGFloat {
    /// Размер сепараторной линии.
    @MainActor
    static var separatorSize: Self {
        return Swift.min(0.5, 1 / UIScreen.main.scale)
    }
}
