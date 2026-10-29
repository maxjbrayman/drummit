//
//  MyGearTab.swift
//  Drummit
//
//  Created by Max Brayman on 10/2/26.
//

import SwiftUI
import SwiftData

struct MyGearTab: View {
    @Query(filter: #Predicate<ImageScanItem>{ item in
        item.isSaved
    }) private var items: [ImageScanItem]
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            MyGearList(items: items)
                .appRouteDestinations()
            
        }
    }
}

#Preview {
    MyGearTab()
}
