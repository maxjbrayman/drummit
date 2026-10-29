//
//  BottomTabNavigator.swift
//  Drummit
//
//  Created by Max Brayman on 10/1/26.
//

import SwiftUI
import SwiftData

struct BottomTabNavigator: View {
    var body: some View {
        TabView {
            Tab("My Gear", systemImage: "bookmark") {
                MyGearTab()
            }
            Tab("Scan", systemImage: "viewfinder") {
                ScansTab()
            }
        }
    }
}

#Preview(traits: .sampleData) {
    BottomTabNavigator()
}
