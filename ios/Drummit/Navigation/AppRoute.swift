//
//  AppRoute.swift
//  Drummit
//
//  Created by Max Brayman on 10/19/26.
//

import SwiftUI

enum AppRoute: Hashable {
    case scanDetails(scan: ImageScan)
    case itemDetails(item: ImageScanItem)
}

extension View {
    func appRouteDestinations() -> some View {
            navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .itemDetails(let item): ItemDetails(item: item)
                case .scanDetails(let scan): ScanDetails(scan: scan)
                }
            }
    }
}
