//
//  PermissionAlert.swift
//  BugsAndTestsSwiftUI
//
//  Created by Admin on 13/05/2021.
//

import SwiftUI

import AVFoundation

struct PermissionAlert: ViewModifier {
    @State private var alertMsg: String = ""
    @ObservedObject var permissionManager = PermissionManager.shared
    func body(content: Content) -> some View {
            content
                .onAppear {
                    permissionManager.requestAccess(.cameraUsage) { granted in
                        
                    }
                    
                }
                .alert(isPresented: $permissionManager.showAlert, content: {
                    Alert(title: Text("Permissions"), message: Text("Permissions"), primaryButton: .default(Text("Ok"), action: {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }), secondaryButton: .cancel())
            })
        
    }
}

//struct PermissionAlertTest: View {
//    @State var isShown: Bool = false
//    var body: some View {
//        Button("lol") {
//            isShown = true
//        }
//            .modifier(PermissionAlert(isPresented: $isShown))
//    }
//}

struct PermissionAlert_Previews: PreviewProvider {
    
    static var previews: some View {
        Text("hihi")
            .modifier(PermissionAlert())
        
    }
}
