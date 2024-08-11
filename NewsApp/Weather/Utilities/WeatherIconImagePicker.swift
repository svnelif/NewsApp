import UIKit

class WeatherIconImagePicker {
    static var cachedIconImages = NSCache<NSString, UIImage>()
    
    static func getImage(named name: String) -> UIImage {
        let convertedName = NSString(string: name)
        guard let wantedImage = cachedIconImages.object(forKey: convertedName) else {
            let newImage = UIImage(named: name) ?? UIImage()
            cachedIconImages.setObject(newImage, forKey: convertedName)
            return newImage
        }
        return wantedImage
    }
}
