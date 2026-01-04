//  AIChatView.swift
import SwiftUI

struct AIChatView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel: AIChatViewModel
    @State private var messageText = ""
    @FocusState private var isInputFocused: Bool
    
    init() {
        _viewModel = StateObject(wrappedValue: AIChatViewModel(
            aiService: AppContainer.shared.aiService
        ))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.messages) { msg in
                                ChatBubble(message: msg).id(msg.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages.count) { _, _ in
                        if let last = viewModel.messages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }
                HStack(spacing: 8) {
                    TextField("Ask me anything...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .focused($isInputFocused)
                        .lineLimit(1...4)
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(messageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(messageText.isEmpty || viewModel.isLoading)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            }
            .navigationTitle("AI Coach")
            .task { await viewModel.loadConversation() }
        }
    }
    
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messageText = ""
        isInputFocused = false
        Task { await viewModel.sendMessage(text) }
    }
}
