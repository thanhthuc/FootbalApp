import UIKit

class ImageCache: NSObject {
    static let imageCache = NSCache<NSString, UIImage>()
}

extension UIImageView {
    
    private func setImage(image: UIImage?) {
        DispatchQueue.main.async {
            self.image = image
        }
    }
    
    func cacheAndSaveImage(_ url: String?) {
        DispatchQueue.global().async { [weak self] in
            // Convert data to image in background
            guard let stringURL = url,
                  let url = URL(string: stringURL) else {
                return
            }
            let urlToString = url.absoluteString as NSString
            
            if let cachedImage = ImageCache.imageCache.object(forKey: urlToString) {
                
                self?.setImage(image: cachedImage)
                
            } else if let data = try? Data(contentsOf: url),
                      let image = UIImage(data: data) {
                // Populate image to UI in main thread
                DispatchQueue.main.async {
                    ImageCache.imageCache.setObject(image, forKey: urlToString)
                    self?.setImage(image: image)
                }
            } else {
                self?.setImage(image: nil)
            }
        }
    }
}
