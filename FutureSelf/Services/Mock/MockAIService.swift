//  MockAIService.swift
import Foundation
import Combine

@MainActor
class MockAIService: AIServiceProtocol {
    private let userId: String
    private let transactionService: MockTransactionService
    private let envelopeService: MockEnvelopeService
    private let goalService: MockGoalService
    private let subject = CurrentValueSubject<[ChatMessage], Never>([])
    var conversationPublisher: AnyPublisher<[ChatMessage], Never> { subject.eraseToAnyPublisher() }
    
    init(userId: String, transactionService: MockTransactionService, envelopeService: MockEnvelopeService, goalService: MockGoalService) {
        self.userId = userId
        self.transactionService = transactionService
        self.envelopeService = envelopeService
        self.goalService = goalService
        subject.send([ChatMessage(role: .assistant, content: "Hi! I'm your FutureSelf AI coach. How can I help you today?")])
    }
    
    func sendMessage(_ message: String, isVoice: Bool) async throws -> ChatMessage {
        var msgs = subject.value
        msgs.append(ChatMessage(role: .user, content: message, isVoice: isVoice))
        let response = generateResponse(for: message)
        let aiMsg = ChatMessage(role: .assistant, content: response)
        msgs.append(aiMsg)
        subject.send(msgs)
        return aiMsg
    }
    
    private func generateResponse(for message: String) -> String {
        let lower = message.lowercased()
        if lower.contains("how am i") || lower.contains("status") {
            return "You're doing great! You've spent $2,450 of your $3,000 budget this month (82%). Your essentials are looking good, and you have 30 days of safety in your emergency fund. Keep up the momentum!"
        }
        if lower.contains("save") || lower.contains("saving") {
            return "You've got 30 days of expenses saved. Every single day you add to that number is a win. You don't need to save $1,000 tomorrow—just $15 this week. Small steps build your future."
        }
        if lower.contains("stress") || lower.contains("worried") {
            return "I hear you. Money stress is real. You're here, you're trying, and that matters. Let's just focus on today. What's one small thing that would make you feel better?"
        }
        return "I'm here to help! You can ask me about your budget, savings goals, or just chat about what's on your mind."
    }
}
