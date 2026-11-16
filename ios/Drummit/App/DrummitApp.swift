//
//  DrummitApp.swift
//  Drummit
//
//  Created by Max Brayman on 10/1/26.
//

import SwiftUI
import SwiftData
import FirebaseAppCheck
import FirebaseCore

@main
struct DrummitApp: App {
    
    let modelContainer: ModelContainer
    @State private var store: ImageScanStore
    
    init() {
        // The factory must be set before configure(), because configure()
        // starts App Check with whichever factory is registered at that moment.
        AppCheck.setAppCheckProviderFactory(DrummitAppCheckProviderFactory())
        FirebaseApp.configure()

        do {
            let schema = Schema([ImageScan.self, ImageScanItem.self])
            let config = ModelConfiguration(schema: schema)
            let modelContainer = try ModelContainer(
                for: schema,
                configurations: config
            )
            self.modelContainer = modelContainer
            
            let client = HttpClient(
                baseURL: AppConfig.apiBaseURL,
                appCheckTokenProvider: FirebaseAppCheckTokenProvider()
            )
            let service = ImageScanService(client: client)
            _store = State(initialValue: ImageScanStore(
                service: service,
                context: modelContainer.mainContext
            ))
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    var body: some Scene {
        WindowGroup {
            BottomTabNavigator()
                .modelContainer(modelContainer)
                .environment(store)
        }
    }
}
