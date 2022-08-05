//
//  VisionaryApp.swift
//  Visionary
//
//  Created by Jake Davies on 29/07/2022.
//

import SwiftUI

@main
struct VisionaryApp: App {
    var body: some Scene {
        WindowGroup {
            CameraView()
                .frame(width: 1920.0 / 1.5, height: 1080.0 / 1.5)
        }
    }
}
