//
//  Scans.swift
//  Drummit
//
//  Created by Max Brayman on 10/13/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct SelectedImage: Identifiable, Equatable {
    let id = UUID()
    let image: Data
}

struct Scans: View {
    let scans: [ImageScan]
    private let spacing: CGFloat = Spacing.md
    private let headerContentHeight: CGFloat = 48
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: SelectedImage? = nil
    
    @State private var searchText = ""
    @State private var scrollY: CGFloat = 0
    @State private var filters = ScansFilters()
    @State private var showFilters = false
    @State private var showCamera = false
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible(), alignment: .top),
            GridItem(.flexible(), alignment: .top)
        ]
    }
    
    private var filteredScans: [ImageScan] {
        scans.filter { scan in
            // favorites filter
            if filters.favoritesOnly {
                let matchesFilter = scan.items.first(where: { item in
                    item.isSaved
                }) != nil
                if !matchesFilter { return false }
            }
            
            // equipment categories filter
            if !filters.categories.isEmpty {
                let matchesFilter = scan.items.first(where: { item in
                    filters.categories.contains(item.equipment.kind.category)
                }) != nil
                if !matchesFilter { return false }
            }
            
            // date range filter
            if filters.dateRange != .anytime {
                let fromDay = Calendar.current.startOfDay(for: filters.fromDate)
                let toDay = Calendar.current.startOfDay(for: filters.toDate)
                let scanDay = Calendar.current.startOfDay(for: scan.dateScanned)
                
                let matchesFilter = scanDay >= fromDay && scanDay <= toDay
                if !matchesFilter { return false }
            }
            
            // search filter
            let text = searchText.lowercased()
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                let searchMatchesTitle = scan.title.lowercased().contains(text)
                if !searchMatchesTitle {
                    // check if search value matches the item description OR search terms
                    let searchMatchesItem = scan.items.first(where: { item in
                        let description = item.equipment.kind.category.displayName
                        
                        // return early if description is matched
                        if description.lowercased().contains(text) { return true }
                        
                        
                        // check search terms if description was not matched
                        if !item.equipment.searchTerms.isEmpty {
                            return item.equipment.searchTerms.first(where: { term in
                                let lowercasedTerm = term.lowercased()
                                // check that either a search term is in the search text OR the text is in a search term
                                return lowercasedTerm
                                    .contains(text) || text
                                    .contains(lowercasedTerm)
                            }) != nil
                        }
                        
                        // if we haven't returned yet then the search text does not match the item
                        return false
                    }) != nil
                    
                    return searchMatchesItem
                }
            }
            
            return true
        }
    }
    
    private var sortedScans: [ImageScan] {
        filteredScans.sorted {
            $0.dateScanned > $1.dateScanned
        }
    }
    
    var body: some View {
        ScrollViewCollapsingHeader(
            collapsedPercentage: .safeArea,
            header: { progress in
                header(progress)
            }) {
                LazyVGrid(columns: columns) {
                    ForEach(sortedScans) { scan in
                        NavigationLink(value: AppRoute.scanDetails(scan: scan)) {
                            ScanPreview(scan: scan)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, spacing)
            }
            .safeAreaInset(edge: .bottom) {
                actionButtons
                    .padding()
                    .background(.regularMaterial)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onChange(of: selectedImage) { _, newValue in
                if newValue == nil {
                    selectedItem = nil
                }
            }
            .onChange(of: selectedItem) { _, newValue in
                guard let newValue else { return }
                
                Task {
                    if let loaded = try? await newValue.loadTransferable(
                        type: Data.self
                    ) {
                        selectedImage = SelectedImage(image: loaded)
                    } else {
                        print("Failed")
                    }
                }
            }
            .sheet(
                item: $selectedImage,
                onDismiss: { selectedImage
                    = nil }
            ) { image in
                NavigationStack {
                    ScannerView(image: image.image)
                        .padding(.top)
                        .safeAreaPadding(.bottom, Spacing.xl)
                        .scannerRouteDestinations()
                }
                .interactiveDismissDisabled()
            }
            .sheet(isPresented: $showCamera) {
                CameraView { image in
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        selectedImage = SelectedImage(image: imageData)
                    }
                }
                .ignoresSafeArea()
            }
            .sheet(isPresented: $showFilters) {
                NavigationStack {
                    ScansFiltersView(filters: $filters)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Cancel") {
                                    showFilters = false
                                }
                            }
                            ToolbarItem(placement: .topBarTrailing) {
                                Button("Reset") {
                                    showFilters = false
                                    filters = ScansFilters()
                                }
                            }
                        }
                        .navigationTitle("Filters")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .interactiveDismissDisabled()
            }
    }
    
    private func header(_ progress: CGFloat) -> some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search scans...", text: $searchText)
                    .font(.system(size: 18))
            }
            .padding(.horizontal, Spacing.sm)
            .frame(height: headerContentHeight)
            .background(
                Color(.tertiarySystemFill),
                in: RoundedRectangle(cornerRadius: CornerRadius.md)
            )
            Button(action: {
                showFilters = true
            }) {
                Image(systemName: "slider.horizontal.3")
            }
            .buttonStyle(.plain)
            .frame(width: headerContentHeight, height: headerContentHeight)
            .background(
                Color(.tertiarySystemFill),
                in: RoundedRectangle(cornerRadius: CornerRadius.md)
            )
        }
        .font(.system(size: 24))
        .padding(.horizontal, spacing)
        .padding(.bottom, spacing)
        .opacity(1 - progress)
    }
    
    private var actionButtons: some View {
        HStack {
            Button("Take photo") {
                showCamera = true
            }
            .buttonStyle(.app(.outline))
            .frame(maxWidth: .infinity)
            PhotosPicker(
                "Upload photo",
                selection: $selectedItem,
                matching: .images
            )
            .buttonStyle(.app(.primary))
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview(traits: .sampleData) {
    @Previewable @Query var scans: [ImageScan]
    NavigationStack {
        Scans(scans: scans)
    }
}
