import Foundation


class LocalizationManager {
    static let shared = LocalizationManager()
    
    func setLanguage(languageCode: String) {
        UserDefaults.standard.set(languageCode, forKey: "appLanguage")
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(languageCode)
    }
    
    func getCurrentLanguage() -> String {
        return UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
    }
}

private var bundleKey: UInt8 = 0

class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        } else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
    }
}

extension Bundle {
    class func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, BundleEx.self)
        }
        
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let languageBundle = Bundle(path: path) else {
            objc_setAssociatedObject(Bundle.main, &bundleKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return
        }
        
        objc_setAssociatedObject(Bundle.main, &bundleKey, languageBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
