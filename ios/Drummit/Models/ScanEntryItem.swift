//
//  ScanEntryItem.swift
//  Drummit
//
//  Created by Max Brayman on 10/28/26.
//

import Foundation

struct ScanItemEntry: Identifiable {
    let number: Int
    let item: ImageScanItem
    
    var id: UUID {
        item.uuid
    }
}

extension Array where Element == ImageScanItem {
    func entries(selectedId: UUID?) -> [ScanItemEntry] {
        let all = enumerated().map { ScanItemEntry(number: $0.offset + 1, item: $0.element) }
        guard let selectedId else { return all }
        return all.filter { $0.item.uuid == selectedId }
    }
}
