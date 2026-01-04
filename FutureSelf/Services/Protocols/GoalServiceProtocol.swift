//  GoalServiceProtocol.swift
import Foundation
import Combine

protocol GoalServiceProtocol {
    var goalsPublisher: AnyPublisher<[Goal], Never> { get }
    func getGoals() async throws -> [Goal]
    func createGoal(_ goal: Goal) async throws -> Goal
    func updateGoal(_ goal: Goal) async throws -> Goal
    func setActiveGoal(id: String) async throws
}
