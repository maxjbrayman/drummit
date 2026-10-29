//
//  ScanDetails.swift
//  Drummit
//
//  Created by Max Brayman on 10/23/26.
//

import SwiftUI

struct ScanDetails: View {
    let scan: ImageScan
    @State private var selectedItemId: UUID? = nil
    @State private var showDeleteAlert = false
    @Environment(ImageScanStore.self) private var scansStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            Section(
                header: ScannedImage(
                    scan: scan,
                    selectedItemId: $selectedItemId
                ).listRowInsets(EdgeInsets()) ) {
                    
                }
                .listSectionMargins(.horizontal, 0)
            Section(
                header: ScannerItemsListHeader(
                    itemsCount: scan.items.count,
                    selectedItemId: $selectedItemId
                )
            ) {
                ForEach(scan.items.entries(selectedId: selectedItemId)) { entry in
                    NavigationLink(value: AppRoute.itemDetails(item: entry.item)) {
                        ScanItemCard(item: entry.item, number: entry.number)
                    }
                }
            }
            Button("Delete Scan") {
                showDeleteAlert = true
            }
            .foregroundStyle(.red)
        }
        .alert("Delete Scan?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                scansStore.deleteScan(scan)
                dismiss()
            }
            Button("Nevermind", role: .cancel) {
                
            }
        } message: {
            Text("This action cannot be undone. Are you sure you want to delete this scan?")
        }
        .navigationTitle(scan.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Previewable @State var selectedId: UUID? = nil
    NavigationStack {
        ScanDetails(scan: ImageScan.samples[0])
            .appRouteDestinations()
    }
}
