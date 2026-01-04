//  MockGoalService.swift
import Foundation
import Combine

@MainActor
class MockGoalService: GoalServiceProtocol {
    private let userId: String
    private let subject = CurrentValueSubject<[Goal], Never>([])
    var goalsPublisher: AnyPublisher<[Goal], Never> { subject.eraseToAnyPublisher() }

    init(userId: String) {
        self.userId = userId
        subject.send([
            Goal(userId: userId, name: "Emergency Fund", description: "Build a 30-day emergency cushion", type: .emergencyFund, targetAmount: 1500, currentAmount: 450, isActive: true),
            Goal(userId: userId, name: "Debt Free", description: "Pay off credit card debt", type: .debtFree, targetAmount: 3000, currentAmount: 1000, isActive: false)
        ])
    }

    func getGoals() async throws -> [Goal] { subject.value }

    func createGoal(_ goal: Goal) async throws -> Goal {
        var goals = subject.value
        goals.append(goal)
        subject.send(goals)
        return goal
    }

    func updateGoal(_ goal: Goal) async throws -> Goal {
        var goals = subject.value
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            subject.send(goals)
        }
        return goal
    }

    func setActiveGoal(id: String) async throws {
        var goals = subject.value
        for index in goals.indices {
            goals[index].isActive = (goals[index].id == id)
        }
        subject.send(goals)
    }
}
