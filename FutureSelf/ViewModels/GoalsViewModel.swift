//  GoalsViewModel.swift
import Foundation
import Combine

@MainActor
class GoalsViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var isLoading = false
    private let goalService: GoalServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(goalService: GoalServiceProtocol) {
        self.goalService = goalService
        goalService.goalsPublisher.receive(on: DispatchQueue.main).assign(to: &$goals)
    }
    
    func loadGoals() async {
        isLoading = true
        defer { isLoading = false }
        do { goals = try await goalService.getGoals() } catch { print("Error: \(error)") }
    }
}
