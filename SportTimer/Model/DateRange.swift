//
//  DateRange.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation

enum DateRange: CaseIterable {
    case all
    case today
    case thisWeek
    case thisMonth
    case last30Days
    
    var displayName: String {
        switch self {
        case .all:
            return "Все время"
        case .today:
            return "Сегодня"
        case .thisWeek:
            return "Эта неделя"
        case .thisMonth:
            return "Этот месяц"
        case .last30Days:
            return "Последние 30 дней"
        }
    }
    
    func contains(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return true
        case .today:
            return calendar.isDate(date, inSameDayAs: now)
        case .thisWeek:
            return calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear)
        case .thisMonth:
            return calendar.isDate(date, equalTo: now, toGranularity: .month)
        case .last30Days:
            return date >= calendar.date(byAdding: .day, value: -30, to: now) ?? now
        }
    }
} 