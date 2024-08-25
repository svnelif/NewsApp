//
//  LocalData.swift
//

import Foundation
import Realm
import RealmSwift

class LocalData {
    static let userDefaults = UserDefaults.standard
    
    static var myData: Double? {
        set {
            userDefaults.set(newValue, forKey: "MyData")
            userDefaults.synchronize()
        }
        
        get {
            userDefaults.object(forKey: "MyData") as? Double
        }
    }
}

class LocalDataManager {
    static let realm = try! Realm(configuration: realmConfig)
    
    class func dropDatabase() {
        try? realm.write {
            realm.deleteAll()
        }
    }
    
    static var realmConfig: Realm.Configuration {
        var config = Realm.Configuration()
        config.deleteRealmIfMigrationNeeded = true
        config.schemaVersion = 1
        return config
        
    }
}

extension LocalDataManager {
    class func getWeatherData() -> Locations? {
        let locationWeatherData = LocalDataManager.realm.object(ofType: Locations.self, forPrimaryKey: "Sofia")
        return locationWeatherData
    }
    
    class func allWeatherData() {
        let allWeatherData = LocalDataManager.realm.objects(WeatherRealm.self)
    }
}
