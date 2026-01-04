//  EnvelopeListView.swift
import SwiftUI

struct EnvelopeListView: View {
    @EnvironmentObject var container: AppContainer
    @StateObject private var viewModel: EnvelopesViewModel
    @State private var showingAddEnvelope = false

    init() {
        _viewModel = StateObject(wrappedValue: EnvelopesViewModel(
            envelopeService: AppContainer.shared.envelopeService
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        if viewModel.envelopes.isEmpty && !viewModel.isLoading {
                            EmptyEnvelopesView()
                        } else {
                            ForEach(viewModel.envelopes) { envelope in
                                NavigationLink(destination: EnvelopeDetailView(envelope: envelope)) {
                                    EnvelopeCard(envelope: envelope)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                }

                if viewModel.isLoading && viewModel.envelopes.isEmpty {
                    ProgressView()
                        .scaleEffect(1.2)
                }
            }
            .navigationTitle("Envelopes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddEnvelope = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEnvelope) {
                AddEnvelopeView()
            }
            .task { await viewModel.loadEnvelopes() }
        }
    }
}

struct EnvelopeCard: View {
    let envelope: Envelope

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: envelope.iconName)
                    .foregroundColor(envelope.color)
                Text(envelope.name).font(.headline)
                Spacer()
                Text(envelope.status.displayName)
                    .font(.caption)
                    .foregroundColor(envelope.status.color)
            }
            ProgressView(value: envelope.percentUsed)
                .tint(envelope.status.color)
                .animation(.easeInOut(duration: 0.5), value: envelope.percentUsed)
            HStack {
                Text("\(envelope.spentAmount as NSDecimalNumber, formatter: currencyFormatter)")
                Text("of \(envelope.budgetAmount as NSDecimalNumber, formatter: currencyFormatter)")
                    .font(.caption).foregroundColor(.secondary)
                Spacer()
                Text("\(envelope.remaining as NSDecimalNumber, formatter: currencyFormatter) left")
                    .font(.caption).foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct EmptyEnvelopesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No Budget Envelopes Yet")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Create your first budget category to start tracking your spending")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Text("Tap the + button above to get started")
                .font(.caption)
                .foregroundColor(.accentColor)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
}

private let currencyFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "USD"
    return f
}()

#Preview {
    EnvelopeListView()
        .environmentObject(AppContainer.shared)
}
