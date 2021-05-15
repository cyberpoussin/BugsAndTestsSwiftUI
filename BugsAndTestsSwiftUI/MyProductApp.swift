//
//  MyProductApp.swift
//  MyProduct
//
//  Created by Adrien on 28/10/2020.
//

import SwiftUI

@main
struct MyProductApp: App {
    init() {
        
        
    }
    var body: some Scene {
        WindowGroup {
            Button("redemander") {
                PermissionManager.shared.requestAccess(.cameraUsage) { granted in
                    
                }
            }
            Text("hihi")
                .modifier(PermissionAlert())
        }
    }
}
