//
//  ScansFilters.swift
//  Drummit
//
//  Created by Max Brayman on 10/26/26.
//

import SwiftUI

enum ScanDateRange: CaseIterable, Hashable {
    case anytime
    case sevenDays
    case thirtyDays
    case custom
    
    var label: String {
        switch self {
        case .anytime:
            "Any time"
        case .sevenDays:
            "7 days"
        case .thirtyDays:
            "30 days"
        case .custom:
            "Custom"
        }
    }
}

struct ScansFilters: Equatable {
    var dateRange: ScanDateRange = .anytime
    var fromDate: Date = .now
    var toDate: Date = .now
    var categories = Set<EquipmentCategory.ID>()
    var favoritesOnly = false
    
    static func == (lhs: ScansFilters, rhs: ScansFilters) -> Bool {
        lhs.categories == rhs.categories &&
        lhs.favoritesOnly == rhs.favoritesOnly &&
        lhs.dateRange == rhs.dateRange &&
        Calendar.current.isDate(lhs.fromDate, inSameDayAs: rhs.fromDate) &&
        Calendar.current.isDate(lhs.toDate, inSameDayAs: rhs.toDate)
    }
}

struct ScansFiltersView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filters: ScansFilters
    @State private var localFilters: ScansFilters = ScansFilters()
    
    init(filters: Binding<ScansFilters>) {
        _filters = filters
        _localFilters = State(initialValue: filters.wrappedValue)
    }
    
    private var minFrom: Date {
        Calendar.current.date(byAdding: .year, value: -1, to: maxFrom)!
    }
    
    private var maxFrom: Date {
        localFilters.toDate
    }
    
    private var minTo: Date {
        localFilters.fromDate
    }
    
    private var maxTo: Date {
        .now
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.xl) {
                dateRangeSection
                gearSection
                myGearSection
            }
            .padding(.horizontal, Spacing.md)
            .onChange(of: localFilters.dateRange, initial: true) {_, newValue in
                onChangeDateRange(newValue)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            Button("Apply Filters") {
                onApplyFilters()
            }
            .buttonStyle(.app(.primary))
            .padding(.horizontal, Spacing.md)
        }
    }
    
    private func onApplyFilters() {
        filters = localFilters
        dismiss()
    }
    
    private func onChangeDateRange(_ range: ScanDateRange) {
        switch range {
        case .anytime:
            localFilters.fromDate = .now
            localFilters.toDate = .now
        case .sevenDays:
            localFilters.fromDate = Calendar.current
                .date(byAdding: .day, value: -7, to: .now)!
            localFilters.toDate = .now
        case .thirtyDays:
            localFilters.fromDate = Calendar.current
                .date(byAdding: .day, value: -30, to: .now)!
            localFilters.toDate = .now
        case .custom: break
        }
    }
    
    private var myGearSection: some View {
        ScansFiltersSection(title: "My Gear") {
            Toggle(isOn: $localFilters.favoritesOnly) {
                VStack(alignment: .leading) {
                    Text("Only scans with saved gear")
                        .font(.headline)
                    Text("Hide scans with nothing in My Gear")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private var gearSection: some View {
        ScansFiltersSection(title: "Includes Gear") {
            if !localFilters.categories.isEmpty {
                Text("\(localFilters.categories.count) selected")
                    .bold(false)
            }
        } content: {
            CapsulePicker(
                items: EquipmentCategory.allCases,
                selectedItems: $localFilters.categories,
                label: { $0.displayName }
            )
            Text("Show scans that contain any of the selected types")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }
    
    private var dateRangeSection: some View {
        ScansFiltersSection(title: "date scanned") {
            Picker("", selection: $localFilters.dateRange) {
                ForEach(ScanDateRange.allCases, id: \.label) { value in
                    Text(value.label)
                        .tag(value)
                    
                }
            }
            .padding(.bottom, Spacing.sm)
            .pickerStyle(.segmented)
            if localFilters.dateRange != .anytime {
                VStack(spacing: 0) {
                    HStack {
                        Text("From")
                        Spacer()
                        DatePicker(
                            "",
                            selection: $localFilters.fromDate,
                            in: minFrom...maxFrom,
                            displayedComponents: [.date]
                        )
                        .disabled(localFilters.dateRange != .custom)
                    }
                    .padding(Spacing.md)
                    Divider()
                    HStack {
                        Text("To")
                        Spacer()
                        DatePicker(
                            "",
                            selection: $localFilters.toDate,
                            in: minTo...maxTo,
                            displayedComponents: [.date]
                        )
                        .disabled(localFilters.dateRange != .custom)
                    }
                    .padding(Spacing.md)
                }
                .background(.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.lg))
                .shadow(radius: 2)
            }
        }
    }
}

struct ScansFiltersSection<Content: View, HeaderRight: View>: View {
    let title: String
    @ViewBuilder let headerRight: () -> HeaderRight
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            HStack {
                Text(title.uppercased())
                Spacer()
                headerRight()
            }
            .bold()
            .foregroundStyle(.secondary)
            content()
        }
    }
}

extension ScansFiltersSection where HeaderRight == EmptyView {
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.init(title: title, headerRight: { EmptyView() }, content: content)
    }
}

#Preview {
    @Previewable @State var filters = ScansFilters()
    ScansFiltersView(filters: $filters)
}
