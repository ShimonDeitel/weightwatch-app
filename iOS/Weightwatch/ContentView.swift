import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingSettings = false
    @State private var showingPaywall = false
    @State private var editingEntry: Entry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                if store.entries.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Weightwatch")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addEntryButton")
                }
            }
            .sheet(isPresented: $showingAdd) {
                EntryEditView(entry: nil) { newEntry in
                    store.add(newEntry)
                }
            }
            .sheet(item: $editingEntry) { entry in
                EntryEditView(entry: entry) { updated in
                    store.update(updated)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
        .tint(Theme.accent)
        .onChange(of: purchases.isPro) { _, newValue in
            store.isPro = newValue
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundStyle(Theme.textSecondary)
            Text("No entries yet")
                .font(Theme.headingFont)
                .foregroundStyle(Theme.textPrimary)
            Text("Tap + to log your first weigh-in.")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .accessibilityIdentifier("emptyState")
    }

    private var list: some View {
        List {
            ForEach(store.entries) { entry in
                Button {
                    editingEntry = entry
                } label: {
                    EntryRow(entry: entry)
                }
                .listRowBackground(Theme.cardBackground)
            }
            .onDelete { offsets in
                store.delete(at: offsets)
            }
        }
        .scrollContentBackground(.hidden)
        .accessibilityIdentifier("entryList")
    }
}

struct EntryRow: View {
    let entry: Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(entry.date, style: .date)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("\(entry.severity)/10")
                    .font(Theme.captionFont.bold())
                    .foregroundStyle(Theme.accent)
            }
            if !entry.note.isEmpty {
                Text(entry.note)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

struct EntryEditView: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var noteFocused: Bool
    let existing: Entry?
    let onSave: (Entry) -> Void

    @State private var date: Date
    @State private var severity: Double
    @State private var noteText: String

    init(entry: Entry?, onSave: @escaping (Entry) -> Void) {
        self.existing = entry
        self.onSave = onSave
        _date = State(initialValue: entry?.date ?? Date())
        _severity = State(initialValue: Double(entry?.severity ?? 5))
        _noteText = State(initialValue: entry?.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    VStack(alignment: .leading) {
                        Text("Severity: \(Int(severity))/10")
                        Slider(value: $severity, in: 0...10, step: 1)
                            .accessibilityIdentifier("severitySlider")
                    }
                }
                Section("Notes") {
                    TextField("Optional note", text: $noteText, axis: .vertical)
                        .focused($noteFocused)
                        .accessibilityIdentifier("noteField")
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                noteFocused = false
            }
            .navigationTitle(existing == nil ? "New Entry" : "Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var entry = existing ?? Entry()
                        entry.date = date
                        entry.severity = Int(severity)
                        entry.note = noteText
                        onSave(entry)
                        dismiss()
                    }
                    .accessibilityIdentifier("saveEntryButton")
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Store())
        .environmentObject(PurchaseManager())
}
