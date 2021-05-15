
import UIKit
import Photos
import Contacts
import AVFoundation

enum Permission {
    case cameraUsage
    case contactUsage
    case photoLibraryUsage
    case microphoneUsage
}

class PermissionManager: ObservableObject {

    @Published var showAlert: Bool = false
    @Published var settingsAlertMsg: String = ""
    init(){}
    public static let shared = PermissionManager()
    
    let PHOTO_LIBRARY_PERMISSION: String = "Require access to Photo library to proceed. Would you like to open settings and grant permission to photo library?"
    let CAMERA_USAGE_PERMISSION: String = "Require access to Camera to proceed. Would you like to open settings and grant permission to camera ?"
    let CONTACT_USAGE_ALERT: String = "Require access to Contact to proceed. Would you like to open Settings and grant permission to Contact?"
    let MICROPHONE_USAGE_ALERT: String = "Require access to microphone to proceed. Would you like to open Settings and grant permissiont to Microphone?"
    
    func showSettingsAlert(msg: String, completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        settingsAlertMsg = msg
        completionHandler(false)
        showAlert = true
    }
    
    func requestAccess(_ permission: Permission,
                       completionHandler: @escaping (_ accessGranted: Bool) -> Void){
        
        switch permission {
  
        case .cameraUsage: ////////////////// Camera
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                completionHandler(true)
            case .denied:
                showSettingsAlert(msg: CAMERA_USAGE_PERMISSION, completionHandler: completionHandler)
            case .restricted, .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        completionHandler(true)
                    } else {
                        DispatchQueue.main.async {
                            self.showSettingsAlert(msg: self.CAMERA_USAGE_PERMISSION, completionHandler: completionHandler)
                        }
                    }
                }
            }
            break
            
            
        case .contactUsage: ///////////////////// Contact
            switch CNContactStore.authorizationStatus(for: .contacts) {
            case .authorized:
                completionHandler(true)
            case .denied:
                showSettingsAlert(msg: CONTACT_USAGE_ALERT, completionHandler: completionHandler)
            case .restricted, .notDetermined:
                CNContactStore.init().requestAccess(for: .contacts) { granted, error in
                    if granted {
                        completionHandler(true)
                    } else {
                        DispatchQueue.main.async {
                            self.showSettingsAlert(msg: self.CONTACT_USAGE_ALERT, completionHandler: completionHandler)
                        }
                    }
                }
            }
            break
            
            
        case .photoLibraryUsage: ///////////////////// Photo library
            switch PHPhotoLibrary.authorizationStatus() {
            case .authorized:
                completionHandler(true)
            case .denied:
                showSettingsAlert(msg: PHOTO_LIBRARY_PERMISSION, completionHandler: completionHandler)
            case .restricted, .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized{
                        completionHandler(true)
                    }else{
                        DispatchQueue.main.async {
                            self.showSettingsAlert(msg: self.PHOTO_LIBRARY_PERMISSION, completionHandler: completionHandler)
                        }
                    }
                }
            case .limited:
                break
            @unknown default:
                break
            }
            break
            
        case .microphoneUsage:  //////////////////////// Microphone usage
            switch AVAudioSession.sharedInstance().recordPermission{
            case .granted:
                completionHandler(true)
                break
            case .denied:
                showSettingsAlert(msg: MICROPHONE_USAGE_ALERT, completionHandler: completionHandler)
                break
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission({ (granted) in
                    if granted{
                        completionHandler(true)
                    }else{
                        DispatchQueue.main.async {
                            self.showSettingsAlert(msg: self.MICROPHONE_USAGE_ALERT, completionHandler: completionHandler)
                        }
                    }
                })
                break
            }
        }
    }
    
    
    
}


/////////////////////////////////////////////////////////////////////////
/////// Don't forget to add permission in info.plist from privacy ///////
/////////////////////////////////////////////////////////////////////////

