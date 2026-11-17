//
//  MyGearList.swift
//  Drummit
//
//  Created by Max Brayman on 10/2/26.
//

import SwiftUI
import SwiftData

enum MyGearSection: String {
    case cymbals = "Cymbals"
    case sticks = "Sticks"
    case drums = "Drums"
    case pedals = "Pedals"
    case other = "Other"
}

struct MyGearListSection: Identifiable {
    let type: MyGearSection
    let items: [ImageScanItem]
    
    var id: String {
        type.rawValue
    }
    
    var sortPriority: Int {
        switch type {
        case .cymbals:
            1
        case .drums:
            2
        case .pedals:
            3
        case .sticks:
            5
        case .other:
            6
        }
    }
}

struct MyGearList: View {
    let items: [ImageScanItem]
    @State private var searchText: String = ""
    
    private var sections: [MyGearListSection] {
        let dictionary = Dictionary(grouping: items) { item in
            getSectionKey(from: item.equipment.kind)
        }
        return dictionary.map { entry in
            MyGearListSection(type: entry.key, items: entry.value)
        }
    }
    
    private var filteredSections: [MyGearListSection] {
        let trimmedSearch = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        if trimmedSearch.isEmpty { return sections }
        
        
        return sections.compactMap { section in
            let filteredItems = section.items.filter { item in
                let description = item.equipment.searchTerms.joined(
                    separator: " "
                ).lowercased()
                return description.contains(searchText.lowercased())
            }
            
            if filteredItems.isEmpty { return nil }
            
            return MyGearListSection(type: section.type, items: filteredItems)
        }
    }
    
    private var sortedSections: [MyGearListSection] {
        filteredSections.sorted {
            $0.sortPriority < $1.sortPriority
        }
    }
    
    var body: some View {
        List {
            ForEach(sortedSections) { section in
                Section(section.id) {
                    ForEach(section.items) { item in
                        NavigationLink(
                            value: AppRoute.itemDetails(item: item)
                        ) {
                            MyGearItemCard(
                                title: item.equipment.displayTitle,
                                description: item.equipment.displayDescription,
                                uiImage: item.scan?.uiImage
                            )
                        }
                    }
                }
            }
        }
        .navigationTitle("My Gear")
        .searchable(text: $searchText, prompt: "Search...")
    }
    
    private func getSectionKey(from equipmentKind: EquipmentKind) -> MyGearSection {
        switch equipmentKind {
        case .cymbal:
                .cymbals
        case .stick:
                .sticks
        case .drum:
                .drums
        case .pedal:
                .pedals
        case .other:
                .other
        }
    }
    
}

#Preview(traits: .sampleData) {
    @Previewable @Query var items: [ImageScanItem]
    NavigationStack {
        MyGearList(items: items)
    }
}
