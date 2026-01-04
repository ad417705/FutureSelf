//  MockStreakService.swift
import Foundation
import Combine

@MainActor
class MockStreakService: StreakServiceProtocol {
    private let userId: String
    private let subject = CurrentValueSubject<[Streak], Never>([])
    var streaksPublisher: AnyPublisher<[Streak], Never> { subject.eraseToAnyPublisher() }
    
    init(userId: String) {
        self.userId = userId
        subject.send([
            Streak(userId: userId, currentCount: 3, longestCount: 5)
        ])
    }
    
    func getStreaks() async throws -> [Streak] { subject.value }
}
