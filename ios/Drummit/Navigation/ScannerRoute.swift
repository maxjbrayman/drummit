//
//  ScannerRoute.swift
//  Drummit
//
//  Created by Max Brayman on 10/21/26.
//

import SwiftUI

enum ScannerRoute: Hashable {
    case itemDetails(item: ImageScanItem)
}

extension View {
    func scannerRouteDestinations() -> some View {
        navigationDestination(for: ScannerRoute.self) { route in
            switch route {
            case .itemDetails(let item): ItemDetails(item: item)
            }
        }
    }
}
