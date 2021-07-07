//
//  MyProductApp.swift
//  MyProduct
//
//  Created by Adrien on 28/10/2020.
//

import SwiftUI

@main
struct MyProductApp: App {
    @StateObject var environmentStore = GLobalStore()
    var body: some Scene {
        WindowGroup {
            MainTest()
                .environmentObject(environmentStore)
//            Button("redemander") {
//                PermissionManager.shared.requestAccess(.cameraUsage) { granted in
//
//                }
//            }
//            Text("hihi")
//                .modifier(PermissionAlert())
        }
    }
}
