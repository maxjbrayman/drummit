//
//  SampleData.swift
//  Drummit
//
//  Created by Max Brayman on 10/13/26.
//

import SwiftUI
import SwiftData

struct SampleData: PreviewModifier {
    static func makeSharedContext() async throws -> ModelContainer {
        let container = try ModelContainer(
            for: ImageScan.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        ImageScan.samples.forEach { container.mainContext.insert($0) }
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self = .modifier(SampleData())
}
