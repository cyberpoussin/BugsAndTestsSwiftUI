//
//  SwiftUIView.swift
//  BugsAndTestsSwiftUI
//
//  Created by Admin on 12/05/2021.
//

import SwiftUI
import AVFoundation

enum SheetType: String, Identifiable {
    case scanner, photoLibrary, camera
    var id: String {
        return self.rawValue
    }
}

struct TestsImagesAndScanner: View {
    @State var isPresenting: SheetType?
    @State var scannedCode: String?
    @State var selectedImage: UIImage?
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                if self.scannedCode != nil {
                    NavigationLink("Next page", destination: Text("haha : \(scannedCode!)"), isActive: .constant(true)).hidden()
                }

                Button("Scan Code") {
                    self.isPresenting = .scanner
                }
                
                Button("Photo lib") {
                    self.isPresenting = .photoLibrary
                }
                
                Button("Camera") {
                    self.isPresenting = .camera
                }
                
                Button("Permissions") {
                    AVCaptureDevice.requestAccess(for: .video) {_ in 
                        
                    }
                }

                Text("-----")
                    .onAppear {
                        scannedCode = nil
                    }
                    
                    .sheet(item: $isPresenting) {sheet in
                        switch sheet {
                        case .scanner:
                            scannerSheet
                        case .photoLibrary:
                            ImagePicker(sourceType: .photoLibrary, selectedImage: $selectedImage)
                        case .camera:
                            ImagePicker(sourceType: .camera, selectedImage: $selectedImage)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
            }
        }
    }

    var scannerSheet: some View {
        CodeScannerView(
            codeTypes: [.ean13],
            showViewfinder: true,
            simulatedDatas: ["000", "111"],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code
                    self.isPresenting = nil
                }
            }
        )
    }
}

struct TestsImagesAndScanner_Previews: PreviewProvider {
    static var previews: some View {
        TestsImagesAndScanner()
    }
}
