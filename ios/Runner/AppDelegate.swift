import UIKit
import Flutter
import AddressBook
import Contacts
import CoreLocation
import Firebase

@objc public enum PermissionStatus: Int {
    case authorized = 0, denied, restricted, unknown
}

@objc public enum PermissionType: Int {
    case contacts = 0, locationAlways, locationWhenInUse, notifications, microphone, camera, photos, reminders, events, bluetooth, motion, storage

    static let allValues = [contacts, locationAlways, locationWhenInUse, notifications, microphone, camera, photos, reminders, events, bluetooth, motion, storage]
}

struct NSUserDefaultsKeys {
    static let requestedInUseToAlwaysUpgrade = "PS_requestedInUseToAlwaysUpgrade"
    static let requestedBluetooth            = "PS_requestedBluetooth"
    static let requestedMotion               = "PS_requestedMotion"
    static let requestedNotifications        = "PS_requestedNotifications"
}

struct InfoPlistKeys {
    static let locationWhenInUse             = "NSLocationWhenInUseUsageDescription"
    static let locationAlways                = "NSLocationAlwaysUsageDescription"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CLLocationManagerDelegate { // , CLLocationManagerDelegate
    lazy var defaults: UserDefaults = {
        return .standard
    }()

    lazy var locationManager : CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        return lm
    }()

    lazy var currentPermission : PermissionType? = nil;
    lazy var flutterResult : FlutterResult? = nil;

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (currentPermission != nil && flutterResult != nil) {
            switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    flutterResult!(PermissionStatus.authorized.rawValue)
                    self.currentPermission = nil
                    self.flutterResult = nil
                case .denied:
                    flutterResult!(PermissionStatus.denied.rawValue)
                    self.currentPermission = nil
                    self.flutterResult = nil
                default:
                    break
            }
        }
    }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController;
    let permissionsChannel = FlutterMethodChannel.init(name: "humbleme/permissions", binaryMessenger: controller)
    let phoneNumberChannel = FlutterMethodChannel.init(name: "humbleme/verifyPhoneNumber", binaryMessenger: controller)

    phoneNumberChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        print(call.method)
        if ("sendVerificationCode" == call.method) {
            self.sendVerificationCode(phoneNumber: call.arguments as! String, result: result)
        } else if ("loginWithPhoneNumber" == call.method) {
            let args = call.arguments as! [String?]
            if let verificationCode = args[1] {
                if let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? args[0] {
                    self.verifyUser(verificationID: verificationID, verificationCode: verificationCode, result: result)
                } else {
                    // Verification ID could not be retrieved
                    result(FlutterError.init(code: "ERROR", message: "Verification ID not available", details: nil))
                }
            } else {
                result(FlutterError.init(code: "ERROR", message: "Verification code cannot be null", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    permissionsChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        print(call.method)
        self.flutterResult = result
        if ("requestPermission" == call.method) {
            let type : Int = call.arguments as! Int;
            let permission : PermissionType = PermissionType.init(rawValue: type)!
            self.currentPermission = permission
            switch (permission) {
                case .contacts:
                    self.requestContacts(result: result)
                case .locationAlways:
                    self.requestLocationAlways(result: result)
                case .locationWhenInUse:
                    self.requestLocationWhenInUse(result: result)
                default:
                    result(FlutterMethodNotImplemented)
            }
        } else if ("getPermissionState" == call.method) {
            let type : Int = call.arguments as! Int;
            let permission : PermissionType = PermissionType.init(rawValue: type)!
            self.currentPermission = permission
            switch (permission) {
                case .contacts:
                    let authorizationStatus = self.statusContacts()
                    result(authorizationStatus.rawValue)
                case .locationAlways:
                    let authorizationStatus = self.statusLocationAlways()
                    result(authorizationStatus.rawValue)
                case .locationWhenInUse:
                    let authorizationStatus = self.statusLocationWhenInUse()
                    result(authorizationStatus.rawValue)
                default:
                    result(FlutterError.init(code: "UNAVAILABLE", message: "Permission status unavailable", details: nil))
            }
        } else if ("getContacts" == call.method) {
            self.getContacts(result: result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
    private func verifyUser(verificationID: String, verificationCode: String, result: @escaping FlutterResult) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        if let user = Auth.auth().currentUser {
            user.linkAndRetrieveData(with: credential) { (authResult, error) in
                if let error = error {
                    result(FlutterError.init(
                        code: "FIREBASE",
                        message: "Email already in use.",
                        details: error.localizedDescription
                    ))
                }
                result(true)
            }
        } else {
            result(FlutterError.init(
                code: "ERROR",
                message: "User not logged in.",
                details: nil
            ))
        }
//        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
//            if let error = error {
//                // An error occurred
//                result(FlutterError.init(
//                    code: "UNKNOWN",
//                    message: error.localizedDescription,
//                    details: nil
//                ))
//            }
//            // Return the signed in user
//            result(true)
//        }
    }
    
    private func sendVerificationCode(phoneNumber: String, result: @escaping FlutterResult) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) {
            (verificationID, error) in
            if let error = error {
                result(FlutterError.init(
                    code: "UNKNOWN",
                    message: error.localizedDescription,
                    details: nil
                ))
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            result(verificationID)
        }
    }

    private func statusContacts() -> PermissionStatus {
        let authorizationStatus : PermissionStatus;
        if #available(iOS 9, *) {
            switch CNContactStore.authorizationStatus(for: CNEntityType.contacts) {
            case .authorized:
                authorizationStatus = PermissionStatus.authorized;
            case .denied:
                authorizationStatus = PermissionStatus.denied;
            case .notDetermined:
                authorizationStatus = PermissionStatus.unknown;
            case .restricted:
                authorizationStatus = PermissionStatus.restricted;
            }
        } else {
            switch ABAddressBookGetAuthorizationStatus() {
            case .authorized:
                authorizationStatus = PermissionStatus.authorized;
            case .denied:
                authorizationStatus = PermissionStatus.denied;
            case .notDetermined:
                authorizationStatus = PermissionStatus.unknown;
            case .restricted:
                authorizationStatus = PermissionStatus.restricted;
            }
        }

        return authorizationStatus;
    }

    private func requestContacts(result: @escaping FlutterResult) {
        let authorizationStatus : PermissionStatus = statusContacts();
        switch (authorizationStatus) {
        case .authorized:
            result(authorizationStatus.rawValue);
        case .denied:
            result(authorizationStatus.rawValue);
        case .restricted, .unknown:
            if #available(iOS 9, *) {
                CNContactStore().requestAccess(for: .contacts, completionHandler: {
                    success, error in
                    if success {
                        result(PermissionStatus.authorized.rawValue);
                    } else {
                        result(PermissionStatus.denied.rawValue);
                    }
                });
            } else {
                ABAddressBookRequestAccessWithCompletion(nil, { success, error in
                    if success {
                        result(PermissionStatus.authorized.rawValue);
                    } else {
                        result(PermissionStatus.denied.rawValue);
                    }
                });
            }
        }
    }

    private func statusLocationAlways() -> PermissionStatus {
        guard CLLocationManager.locationServicesEnabled() else { return .restricted }

        let status = CLLocationManager.authorizationStatus();
        switch (status) {
        case .authorizedAlways:
            return .authorized;
        case .restricted, .denied:
            return .denied;
        case .authorizedWhenInUse:
            if defaults.bool(forKey: NSUserDefaultsKeys.requestedInUseToAlwaysUpgrade) {
                return .denied
            } else {
                return .unknown
            }
        case .notDetermined:
            return .unknown
        }
    }

    private func statusLocationWhenInUse() -> PermissionStatus {
        guard CLLocationManager.locationServicesEnabled() else { return .restricted }

        let status = CLLocationManager.authorizationStatus()
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            return .authorized
        case .restricted, .denied:
            return .denied
        case .notDetermined:
            return .unknown
        }
    }

    private func requestLocationAlways(result: @escaping FlutterResult) {
        let status = statusLocationAlways()
        switch status {
        case .unknown:
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                defaults.set(true, forKey: NSUserDefaultsKeys.requestedInUseToAlwaysUpgrade)
                defaults.synchronize()
            }
            locationManager.requestAlwaysAuthorization()
        default:
            result(status.rawValue)
        }
    }

    private func requestLocationWhenInUse(result: @escaping FlutterResult) {
        let status = statusLocationWhenInUse()
        switch status {
        case .unknown:
            locationManager.requestWhenInUseAuthorization()
        default:
            result(status.rawValue)
        }
    }

    // Get the user's contacts stored in the phone. These are not stored anywhere and are only used
    // to retrieve users in Firebase with matching phone numbers to help users find their friends.
    private func getContacts(result: @escaping FlutterResult) {
        let status = statusContacts();
        
        // Only continue if we've gotten permission
        if (status == PermissionStatus.authorized) {
            if #available(iOS 9, *) {
                let contactStore = CNContactStore()
                var contacts = [[String: String?]]()
                let keys = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey] as! [CNKeyDescriptor]
                let request = CNContactFetchRequest(keysToFetch: keys)

                do {
                    try contactStore.enumerateContacts(with: request) {
                        (contact, stop) in
                        var contactData = [String: String]()
                        let fullName = contact.givenName + " " + contact.familyName
                        contactData["NAME"] = fullName
                        if (!contact.phoneNumbers.isEmpty) {
                            for number in contact.phoneNumbers {
                                switch (number.label) {
                                case CNLabelPhoneNumberMain:
                                    contactData["MAIN"] = number.value.stringValue
                                    break
                                case CNLabelPhoneNumberMobile:
                                    contactData["MOBILE"] = number.value.stringValue
                                    break
                                case CNLabelPhoneNumberiPhone:
                                    contactData["IPHONE"] = number.value.stringValue
                                    break
                                default:
                                    continue
                                }
                            }
                        }
                        contacts.append(contactData) // ["NAME": fullName, "MAIN": phoneNumber, "MOBILE": phoneNumber, "IPHONE": phoneNumber]
                    }
                } catch {
                    result(FlutterError.init(code: "UNAVAILABLE", message: "Unable to fetch contacts.", details: nil))
                }
                result(contacts)
            }
        } else {
            // Return no contacts
            result(nil)
        }
    }
}
