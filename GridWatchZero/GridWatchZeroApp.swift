//
//  GridWatchZeroApp.swift
//  Grid Watch Zero
//
//  Created by War Signal on 1/19/26.
//

import SwiftUI

@main
struct GridWatchZeroApp: App {

    init() {
        // Migrate save data from old "ProjectPlague" brand to new "GridWatchZero" brand
        // This preserves player progress when updating from pre-rename versions
        BrandMigrationManager.migrateIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootNavigationView()
        }
    }
}
