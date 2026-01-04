//  ChatBubble.swift
import SwiftUI

struct ChatBubble: View {
    let message: ChatMessage
    private var isUser: Bool { message.role == .user }
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundColor(isUser ? .white : .primary)
                    .padding(8)
                    .background(isUser ? Color.blue : Color(.secondarySystemBackground))
                    .cornerRadius(12)
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            if !isUser { Spacer() }
        }
    }
}
