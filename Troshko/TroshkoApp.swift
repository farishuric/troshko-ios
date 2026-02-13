//
//  TroshkoApp.swift
//  Troshko
//
//  Created by Faris Hurić on 17. 9. 2023..
//

import SwiftUI

@main
struct TroshkoApp: App {
    // CoreData
    private var coreDataManager: CoreDataManager = CoreDataManager()

    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}
