//  AIChatViewModel.swift
import Foundation
import Combine

@MainActor
class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    private let aiService: AIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(aiService: AIServiceProtocol) {
        self.aiService = aiService
        aiService.conversationPublisher.receive(on: DispatchQueue.main).assign(to: &$messages)
    }
    
    func loadConversation() async {
        isLoading = true
        isLoading = false
    }
    
    func sendMessage(_ text: String, isVoice: Bool = false) async {
        isLoading = true
        defer { isLoading = false }
        do { _ = try await aiService.sendMessage(text, isVoice: isVoice) } catch { print("Error: \(error)") }
    }
}
