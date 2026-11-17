//
//  ItemDetails.swift
//  Drummit
//
//  Created by Max Brayman on 10/11/26.
//

import SwiftUI
import WebKit
import SwiftData

struct DetailPair: Identifiable {
    let key: String
    let value: String
    
    var id: String { key }
}

struct SelectedURL: Identifiable {
    let url: URL
    
    var id: String {
        url.absoluteString
    }
}

struct ItemDetails: View {
    @State private var selectedUrl: SelectedURL? = nil
    var item: ImageScanItem
    
    private var detailPairs: [DetailPair] {
        var details: [DetailPair] = []
        if let brand = item.equipment.brand {
            details.append(DetailPair(key: "Brand", value: brand))
        }
        
        if let model = item.equipment.model {
            details.append(DetailPair(key: "Model", value: model))
        }
        
        var itemType: String? = nil
        var itemSize: String? = nil
        
        switch item.equipment.kind {
        case .cymbal(let type, let size):
            if let type {
                itemType = type.displayName
            }
            if let size {
                itemSize = "\(size.formatted())"
            }
        case .drum(let type, _, let diameter):
            if let type {
                itemType = type.displayName
            }
            if let diameter {
                itemSize = "\(diameter.formatted())"
            }
            
        case .stick(let type):
            if let type { itemType = type.displayName }
            
        default: break
        }
        
        
        if let itemType {
            details.append(DetailPair(key: "Type", value: itemType))
        }
        
        if let itemSize {
            details.append(DetailPair(key: "Size", value: itemSize))
        }
        
        return details
    }
    
    private func goToRetailer(_ url: URL) {
        selectedUrl = SelectedURL(url: url)
    }
    
    var body: some View {
        List {
            scanConfidenceCardSection
            itemDetailsSection
            retailLinksSection
            if let scan = item.scan {
                NavigationLink(value: AppRoute.scanDetails(scan: scan)) {
                    HStack {
                        Text("View Scan")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                }
                .navigationLinkIndicatorVisibility(.hidden)
                .foregroundStyle(.brandPrimary)
            }
            }
            .navigationTitle(item.equipment.displayTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { item.isSaved.toggle() }) {
                        Image(systemName: item.isSaved ? "star.fill" : "star")
                            .foregroundStyle(.brandAccent)
                    }
                    .buttonStyle(.plain)
                }
            }
            .sheet(item: $selectedUrl, onDismiss: {
                selectedUrl = nil
            }) { item in
                NavigationStack {
                    WebView(url: item.url)
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Done") {
                                    selectedUrl = nil
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .toolbarBackground(.screenBackground, for: .navigationBar)
                }
            }
        
    }
    
    @ViewBuilder private var scanConfidenceCardSection: some View {
        if let scanConfidence = item.confidence {
            Section {
                VStack(alignment: .leading) {
                    Text(scanConfidence.level.displayText)
                        .bold()
                    if let explanation = scanConfidence.explanation {
                        Text(explanation)
                    }
                }
            }
        }
    }
    
    @ViewBuilder private var itemDetailsSection: some View {
        if !detailPairs.isEmpty {
            Section {
                ForEach(detailPairs) { pair in
                    LabeledContent(pair.key, value: pair.value)
                }
                
            }
        }
    }
    
    @ViewBuilder private var retailLinksSection: some View {
        if !item.equipment.urls.isEmpty {
            Section("Research and buy") {
                ForEach(item.equipment.urls) { item in
                    Button(action: { goToRetailer(item.url) }) {
                        HStack {
                            Text(item.retailer.displayName)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.link)
                }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Query var items: [ImageScanItem] = []
    
    return NavigationStack {
        ItemDetails(
            item: items[1]
        )
    }
}
