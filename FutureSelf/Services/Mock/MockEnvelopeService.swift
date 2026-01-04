//  MockEnvelopeService.swift
import Foundation
import Combine

@MainActor
class MockEnvelopeService: EnvelopeServiceProtocol {
    private let userId: String
    private let subject = CurrentValueSubject<[Envelope], Never>([])
    var envelopesPublisher: AnyPublisher<[Envelope], Never> { subject.eraseToAnyPublisher() }
    
    init(userId: String) {
        self.userId = userId
        subject.send([
            Envelope(userId: userId, name: "Housing", budgetAmount: 1200, spentAmount: 1200, iconName: "house.fill", colorHex: "#3B82F6", isEssential: true),
            Envelope(userId: userId, name: "Utilities", budgetAmount: 200, spentAmount: 150, iconName: "bolt.fill", colorHex: "#14B8A6", isEssential: true),
            Envelope(userId: userId, name: "Food", budgetAmount: 500, spentAmount: 380, iconName: "fork.knife", colorHex: "#22C55E", isEssential: true),
            Envelope(userId: userId, name: "Transportation", budgetAmount: 300, spentAmount: 220, iconName: "car.fill", colorHex: "#F97316"),
            Envelope(userId: userId, name: "Entertainment", budgetAmount: 150, spentAmount: 85, iconName: "tv.fill", colorHex: "#A855F7")
        ])
    }
    
    func getEnvelopes() async throws -> [Envelope] { subject.value }

    func createEnvelope(_ envelope: Envelope) async throws -> Envelope {
        var envelopes = subject.value
        envelopes.append(envelope)
        subject.send(envelopes)
        return envelope
    }

    func updateEnvelope(_ envelope: Envelope) async throws -> Envelope {
        var envelopes = subject.value
        if let index = envelopes.firstIndex(where: { $0.id == envelope.id }) {
            envelopes[index] = envelope
            subject.send(envelopes)
        }
        return envelope
    }

    func addSpending(envelopeId: String, amount: Decimal) async throws {
        var envelopes = subject.value
        if let index = envelopes.firstIndex(where: { $0.id == envelopeId }) {
            envelopes[index].spentAmount += amount
            subject.send(envelopes)
        }
    }
}
