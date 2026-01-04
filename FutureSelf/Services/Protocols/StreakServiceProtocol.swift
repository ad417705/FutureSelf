//  StreakServiceProtocol.swift
import Foundation
import Combine

protocol StreakServiceProtocol {
    var streaksPublisher: AnyPublisher<[Streak], Never> { get }
    func getStreaks() async throws -> [Streak]
}
