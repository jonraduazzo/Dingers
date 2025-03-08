//
//  Dingers_PrototypeApp.swift
//  Dingers Prototype
//
//  Created by Justin DeVuono on 12/15/24.
//

import SwiftUI

@main
struct Dingers_PrototypeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .landscape
    }
}
