//  Streak.swift
import Foundation

struct Streak: Identifiable, Codable {
    let id: String
    let userId: String
    var currentCount: Int
    var longestCount: Int
    
    init(id: String = UUID().uuidString, userId: String, currentCount: Int = 0, longestCount: Int = 0) {
        self.id = id
        self.userId = userId
        self.currentCount = currentCount
        self.longestCount = longestCount
    }
}
