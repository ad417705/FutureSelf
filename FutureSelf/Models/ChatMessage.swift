//  ChatMessage.swift
import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: String
    var role: MessageRole
    var content: String
    var timestamp: Date
    var isVoice: Bool
    
    enum MessageRole: String, Codable {
        case user, assistant, system
    }
    
    init(id: String = UUID().uuidString, role: MessageRole, content: String, timestamp: Date = Date(), isVoice: Bool = false) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.isVoice = isVoice
    }
}
