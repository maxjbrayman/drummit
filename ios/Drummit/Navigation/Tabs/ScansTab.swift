//
//  ScansTab.swift
//  Drummit
//
//  Created by Max Brayman on 10/13/26.
//

import SwiftUI
import SwiftData

struct ScansTab: View {
    @Query private var scans: [ImageScan]
    @State private var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            Scans(scans: scans)
                .appRouteDestinations()
        }
    }
}

#Preview {
    ScansTab()
}
