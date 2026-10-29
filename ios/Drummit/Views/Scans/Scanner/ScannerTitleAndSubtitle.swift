//
//  ScannerTitleAndSubtitle.swift
//  Drummit
//
//  Created by Max Brayman on 10/23/26.
//

import SwiftUI

struct ScannerTitleAndSubtitle: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        Text(title)
            .font(.title)
            .bold()
        Text(subtitle)
    }
}
