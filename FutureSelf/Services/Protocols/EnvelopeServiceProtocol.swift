//  EnvelopeServiceProtocol.swift
import Foundation
import Combine

protocol EnvelopeServiceProtocol {
    var envelopesPublisher: AnyPublisher<[Envelope], Never> { get }
    func getEnvelopes() async throws -> [Envelope]
    func createEnvelope(_ envelope: Envelope) async throws -> Envelope
    func updateEnvelope(_ envelope: Envelope) async throws -> Envelope
    func addSpending(envelopeId: String, amount: Decimal) async throws
}
