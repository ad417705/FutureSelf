//  EnvelopesViewModel.swift
import Foundation
import Combine

@MainActor
class EnvelopesViewModel: ObservableObject {
    @Published var envelopes: [Envelope] = []
    @Published var isLoading = false
    private let envelopeService: EnvelopeServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(envelopeService: EnvelopeServiceProtocol) {
        self.envelopeService = envelopeService
        envelopeService.envelopesPublisher.receive(on: DispatchQueue.main).assign(to: &$envelopes)
    }
    
    func loadEnvelopes() async {
        isLoading = true
        defer { isLoading = false }
        do { envelopes = try await envelopeService.getEnvelopes() } catch { print("Error: \(error)") }
    }
}
