//
//  ScopeSelectorView.swift
//  BobTheBuilder
//
//  View for selecting access scope (trades, areas, phases)
//

import SwiftUI

struct ScopeSelectorView: View {
    @SwiftUI.Environment(\.presentationMode) var presentationMode
    @Binding var selectedScope: UserScope?

    let projectId: String
    let availableTrades: [String]
    let availableAreas: [String]
    let availablePhases: [String]

    @State private var selectedTrades: Set<String>
    @State private var selectedAreas: Set<String>
    @State private var selectedPhases: Set<String>
    @State private var scopeType: ScopeSelectionType = .trades

    init(
        projectId: String,
        selectedScope: Binding<UserScope?>,
        availableTrades: [String] = [],
        availableAreas: [String] = [],
        availablePhases: [String] = []
    ) {
        self.projectId = projectId
        self._selectedScope = selectedScope
        self.availableTrades = availableTrades
        self.availableAreas = availableAreas
        self.availablePhases = availablePhases

        // Initialize state from binding
        let scope = selectedScope.wrappedValue
        _selectedTrades = State(initialValue: Set(scope?.trades ?? []))
        _selectedAreas = State(initialValue: Set(scope?.areas ?? []))
        _selectedPhases = State(initialValue: Set(scope?.phases ?? []))
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Scope Type Picker
                Picker("Scope Type", selection: $scopeType) {
                    Text("Trades").tag(ScopeSelectionType.trades)
                    Text("Areas").tag(ScopeSelectionType.areas)
                    Text("Phases").tag(ScopeSelectionType.phases)
                }
                .pickerStyle(.segmented)
                .padding()

                // Selection Summary
                if hasSelections {
                    SelectionSummaryCard(
                        tradesCount: selectedTrades.count,
                        areasCount: selectedAreas.count,
                        phasesCount: selectedPhases.count
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }

                // Selection List
                List {
                    switch scopeType {
                    case .trades:
                        ScopeSelectionSection(
                            title: "Select Trades",
                            icon: "wrench.and.screwdriver",
                            items: availableTrades,
                            selectedItems: $selectedTrades,
                            color: .blue,
                            emptyMessage: "No trades available in this project"
                        )

                    case .areas:
                        ScopeSelectionSection(
                            title: "Select Areas",
                            icon: "mappin.and.ellipse",
                            items: availableAreas,
                            selectedItems: $selectedAreas,
                            color: .green,
                            emptyMessage: "No areas defined in this project"
                        )

                    case .phases:
                        ScopeSelectionSection(
                            title: "Select Phases",
                            icon: "calendar",
                            items: availablePhases,
                            selectedItems: $selectedPhases,
                            color: .orange,
                            emptyMessage: "No phases defined in this project"
                        )
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Configure Scope")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        applySelection()
                    }
                    .disabled(!hasSelections)
                }
            }
        }
    }

    private var hasSelections: Bool {
        !selectedTrades.isEmpty || !selectedAreas.isEmpty || !selectedPhases.isEmpty
    }

    private func applySelection() {
        selectedScope = UserScope(
            trades: selectedTrades.isEmpty ? nil : Array(selectedTrades),
            areas: selectedAreas.isEmpty ? nil : Array(selectedAreas),
            phases: selectedPhases.isEmpty ? nil : Array(selectedPhases)
        )
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Scope Selection Type

enum ScopeSelectionType {
    case trades
    case areas
    case phases
}

// MARK: - Selection Summary Card

struct SelectionSummaryCard: View {
    let tradesCount: Int
    let areasCount: Int
    let phasesCount: Int

    var body: some View {
        HStack(spacing: 16) {
            if tradesCount > 0 {
                SummaryBadge(count: tradesCount, label: "Trade", icon: "wrench.and.screwdriver", color: .blue)
            }
            if areasCount > 0 {
                SummaryBadge(count: areasCount, label: "Area", icon: "mappin.and.ellipse", color: .green)
            }
            if phasesCount > 0 {
                SummaryBadge(count: phasesCount, label: "Phase", icon: "calendar", color: .orange)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct SummaryBadge: View {
    let count: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text("\(count)")
                .font(.headline)
                .foregroundColor(.primary)

            Text(count == 1 ? label : label + "s")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Scope Selection Section

struct ScopeSelectionSection: View {
    let title: String
    let icon: String
    let items: [String]
    @Binding var selectedItems: Set<String>
    let color: Color
    let emptyMessage: String

    var body: some View {
        Section {
            if items.isEmpty {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.secondary)
                    Text(emptyMessage)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            } else {
                ForEach(items, id: \.self) { item in
                    ScopeItemRow(
                        item: item,
                        icon: icon,
                        color: color,
                        isSelected: selectedItems.contains(item)
                    ) {
                        toggleSelection(item)
                    }
                }
            }
        } header: {
            Label(title, systemImage: icon)
                .foregroundColor(color)
        } footer: {
            if !items.isEmpty {
                Text("Select one or more \(title.lowercased()) to limit access")
                    .font(.caption)
            }
        }
    }

    private func toggleSelection(_ item: String) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
        } else {
            selectedItems.insert(item)
        }
    }
}

// MARK: - Scope Item Row

struct ScopeItemRow: View {
    let item: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(isSelected ? color : .secondary)
                    .frame(width: 24)

                Text(item)
                    .foregroundColor(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(color)
                        .font(.title3)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview




