//  Date+Extensions.swift
import Foundation

extension Date {
    var startOfMonth: Date {
        let cal = Calendar.current
        let comps = cal.dateComponents([.year, .month], from: self)
        return cal.date(from: comps) ?? self
    }
    
    var endOfMonth: Date {
        let cal = Calendar.current
        guard let next = cal.date(byAdding: .month, value: 1, to: startOfMonth),
              let end = cal.date(byAdding: .day, value: -1, to: next) else { return self }
        return cal.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? self
    }
}
