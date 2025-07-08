//
//  DateRange.swift
//  SportTimer
//
//  Created by Георгий Борисов on 08.07.2025.
//

import Foundation
import CoreData

enum DateRange: String, CaseIterable {
    case all = "all"
    case today = "today"
    case thisWeek = "thisWeek"
    case thisMonth = "thisMonth"
    case lastMonth = "lastMonth"
    
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
        case .lastMonth:
            return "Прошлый месяц"
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
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            return calendar.isDate(date, equalTo: lastMonth, toGranularity: .month)
        }
    }
    
    /// Создает NSPredicate для фильтрации в Core Data
    var predicate: NSPredicate {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .all:
            return NSPredicate(value: true)
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? now
            return NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        case .thisWeek:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.end ?? now
            return NSPredicate(format: "date >= %@ AND date < %@", startOfWeek as NSDate, endOfWeek as NSDate)
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.dateInterval(of: .month, for: now)?.end ?? now
            return NSPredicate(format: "date >= %@ AND date < %@", startOfMonth as NSDate, endOfMonth as NSDate)
        case .lastMonth:
            let lastMonth = calendar.date(byAdding: .month, value: -1, to: now) ?? now
            let startOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.start ?? now
            let endOfLastMonth = calendar.dateInterval(of: .month, for: lastMonth)?.end ?? now
            return NSPredicate(format: "date >= %@ AND date < %@", startOfLastMonth as NSDate, endOfLastMonth as NSDate)
        }
    }
} 