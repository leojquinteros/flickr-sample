//
//  flickr_sampleApp.swift
//  flickr-sample
//
//  Created by Leo Quinteros on 11/06/23.
//

import SwiftUI

@main
struct flickr_sampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewModel())
        }
    }
}
