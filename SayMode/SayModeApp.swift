//
//  SayModeApp.swift
//  SayMode
//
//  Created by KHALED on 26/11/2026.
//

import DesignSystem
import SwiftUI

@main
struct SayModeApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

/// Picks the first screen. Debug builds can open the DesignSystem gallery for UI tests.
private struct RootView: View {
    var body: some View {
        #if DEBUG
        if let options = DebugLaunchOptions.current() {
            DebugScreen(options: options)
        } else {
            ContentView()
        }
        #else
        ContentView()
        #endif
    }
}

#if DEBUG
private struct DebugScreen: View {
    let options: DebugLaunchOptions

    var body: some View {
        switch options.screen {
        case .gallery:
            // A pinned size is a range of one size. With no size given, the full range keeps the system setting live.
            DesignSystemGallery()
                .dynamicTypeSize(options.dynamicTypeSize.map { $0...$0 } ?? DynamicTypeSize.xSmall...DynamicTypeSize.accessibility5)
                .preferredColorScheme(options.colorScheme)
                .environment(\.dsShowsGroundGrain, options.showsGroundGrain)
        }
    }
}
#endif
