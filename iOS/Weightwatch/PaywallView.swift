import SwiftUI

struct PaywallView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Theme.accent)
                    Text("Weightwatch Pro")
                        .font(Theme.titleFont)
                        .foregroundStyle(Theme.textPrimary)
                    Text("Multi-metric Tracking + CSV Export")
                        .font(Theme.bodyFont)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    if let product = purchases.product {
                        Text(product.displayPrice + (""))
                            .font(Theme.headingFont)
                            .foregroundStyle(Theme.accent)
                    }

                    Button {
                        Task {
                            await purchases.purchase()
                            if purchases.isPro { dismiss() }
                        }
                    } label: {
                        Text(purchases.purchaseInFlight ? "Purchasing..." : "Unlock Pro")
                            .font(Theme.headingFont)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Theme.accent)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
                    }
                    .disabled(purchases.purchaseInFlight || purchases.product == nil)
                    .accessibilityIdentifier("unlockProButton")
                    .padding(.horizontal)

                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)

                    Button("Not now") { dismiss() }
                        .font(Theme.captionFont)
                        .foregroundStyle(Theme.textSecondary)
                        .accessibilityIdentifier("dismissPaywallButton")
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .task { await purchases.load() }
    }
}

#Preview {
    PaywallView().environmentObject(PurchaseManager())
}
