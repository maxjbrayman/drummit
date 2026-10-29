//
//  Scanner.swift
//  Drummit
//
//  Created by Max Brayman on 10/16/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct ScannerView: View {
    let image: Data
    var fileName: String? = nil
    
    @Environment(ImageScanStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var scanTask: Task<Void, Never>? = nil
    @State private var loadState: LoadState<ImageScan> = .idle
    @State private var selectedItemId: UUID? = nil
    @State private var titleText: String = ""
    
    private let shadowRadius: CGFloat = 1.5
    
    private var isScanDisabled: Bool {
        if case .loading = loadState { return true }
        
        return false
    }
    
    private var displayableImage: Image {
        Image(uiImage: UIImage(data: image)!)
    }
        
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                headerContent
                imageContent
                bottomContent
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
        .safeAreaInset(edge: .bottom) {
            footer
                .padding(.top, Spacing.sm)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .scrollDismissesKeyboard(.interactively)
    }
    
    @ViewBuilder private var headerContent: some View {
        if scanTask?.isCancelled == true {
            ScannerTitleAndSubtitle(title: "Scan canceled", subtitle: "Tap 'Scan image' to try again or 'Cancel' to go back.")
        } else {
            switch loadState {
            case .loading:
                ScannerTitleAndSubtitle(title: "Scanning...", subtitle: "This may take up to a minute.")
            case .error:
                ScannerTitleAndSubtitle(title: "Scanning failed", subtitle: "Your photo is still here, so you can try again.")
            case .success(let scan):
                ScannerSuccessHeader(itemCount: scan.items.count, titleText: $titleText)
            case .idle:
                ScannerTitleAndSubtitle(title: "Ready to scan?", subtitle: "Check that this is the photo you want identified.")
            }
        }
    }
    
    @ViewBuilder private var imageContent: some View {
        if case let .success(value) = loadState {
            ScannedImage(
                scan: value,
                selectedItemId: $selectedItemId
            )
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        } else {
            displayableImage
                .resizable()
                .scaledToFit()
                .overlay {
                    switch loadState {
                    case .loading: ScanningOverlay()
                    case .error(let message): ScannerErrorOverlay(errorMessage: message)
                    case .idle, .success: EmptyView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
        }
    }
    
    @ViewBuilder private var bottomContent: some View {
        switch loadState {
        case .loading:
            ScannerLoadingView()
                .padding(.top)
        case .error:
            EmptyView()
        case .success(let scan):
            Section(header: ScannerItemsListHeader(
                itemsCount: scan.items.count,
                selectedItemId: $selectedItemId,
                showItemsCount: false
            )) {
                let items = scan.items.entries(selectedId: selectedItemId)
                
                if !items.isEmpty {
                    VStack {
                        ForEach(
                            items.enumerated(), id: \.element.id) { (index, entry) in
                                NavigationLink(value: ScannerRoute.itemDetails(item: entry.item)) {
                                    ScanItemCard(item: entry.item, number: entry.number) {
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(.tertiary)
                                            .font(.footnote.weight(.bold))
                                    }
                                }
                                .buttonStyle(.plain)
                                if index < items.count - 1 {
                                    Divider()
                                }
                            }
                    }
                    .padding(.vertical)
                    .padding(.horizontal, Spacing.sm)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: CornerRadius.md))
                    .shadow(radius: shadowRadius)                    
                }
            }
        case .idle:
            imageTipView
        }
    }
    
    @ViewBuilder private var footer: some View {
        VStack {
            switch loadState {
            case .error:
                Button(action: startScan) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Try again")
                    }
                }
                .buttonStyle(.app(.primary))
            case .success(let scan):
                if !scan.items.isEmpty {
                    Button("Save scan") {
                        saveScan(scan)
                    }
                    .buttonStyle(.app(.primary))
                    .disabled(
                        titleText
                            .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    )
                }
            case .idle, .loading:
                Button("Scan image") {
                    startScan()
                }
                .buttonStyle(.app(.primary))
                .disabled(isScanDisabled)
            }
            
            switch loadState {
            case .idle, .error:
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.app(.outline))
                .disabled(isScanDisabled)
            case .loading:
                Button("Cancel scan") {
                    cancelScan()
                }
                .buttonStyle(.app(.outline))
            case .success:
                Button("Discard") {
                    dismiss()
                }
                .buttonStyle(.app(.outline, tint: .red))
            }
        }
        .padding(.horizontal)
        .background(.white)
    }
    
    private var imageTipView: some View {
        HStack(alignment: .top) {
            Image(systemName: "info.circle")
                .foregroundStyle(.brandPrimary)
            Text("Clear, well-lit shots with visible logos give the most accurate brand and model matches.")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.xs)
        .background(RoundedRectangle(cornerRadius: CornerRadius.md).fill(.white).shadow(radius: shadowRadius))
    }
    
    private func startScan() {
        scanTask?.cancel()
        scanTask = Task {
            await scan()
        }
    }
    
    private func cancelScan() {
        scanTask?.cancel()
    }
    
    private func scan() async {
        do {
            loadState = .loading
            let name = fileName ?? "\(UUID()).jpeg"
            
            let response = try await store.scanImage(image, fileName: name)
            
            let imageScan = ImageScan(dto: response, imageData: image)
            loadState = .success(imageScan)
            titleText = imageScan.title
        } catch is CancellationError {
            loadState = .idle
        } catch let error as URLError where error.code == .cancelled {
            loadState = .idle
        } catch let error as HttpError {
            loadState = .error(error.message)
        } catch {
            loadState = .error(error.localizedDescription)
        }
    }
    
    private func saveScan(_ initialScan: ImageScan) {
        let trimmedTitle = titleText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let scan = initialScan.title == trimmedTitle ? initialScan : ImageScan(
            title: trimmedTitle,
            dateScanned: initialScan.dateScanned,
            imageData: initialScan.imageData,
            items: initialScan.items
        )
        store.save(scan)
        dismiss()
    }
}
