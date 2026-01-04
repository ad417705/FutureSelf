//  AIServiceProtocol.swift
import Foundation
import Combine

protocol AIServiceProtocol {
    var conversationPublisher: AnyPublisher<[ChatMessage], Never> { get }
    func sendMessage(_ message: String, isVoice: Bool) async throws -> ChatMessage
}
