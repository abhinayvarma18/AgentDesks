//
//Created by Abhinay Varma
//CopyRights Reserved
//

import UIKit
import LBTAComponents

/**
 A convenient UIImageView to load and cache images.
 */
open class ImageCacher: UIImageView {
    
    var offlineImage:UIImage?
    open static let imageCache = NSCache<NSString, DiscardableImageCacheItem>()
    
    open var shouldUseEmptyImage = true
    
    private var urlStringForChecking: String?
    private var emptyImage: UIImage?
    
    public convenience init(cornerRadius: CGFloat = 0, tapCallback: @escaping (() ->())) {
        self.init(cornerRadius: cornerRadius, emptyImage: nil)
        self.tapCallback = tapCallback
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    @objc func handleTap() {
        tapCallback?()
    }
    
    private var tapCallback: (() -> ())?
    
    public init(cornerRadius: CGFloat = 0, emptyImage: UIImage? = nil) {
        super.init(frame: .zero)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        self.emptyImage = emptyImage
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setImage(){
        self.image = image
    }
    
    /**
     Easily load an image from a URL string and cache it to reduce network overhead later.
     
     - parameter urlString: The url location of your image, usually on a remote server somewhere.
     - parameter completion: Optionally execute some task after the image download completes
     */
    
    open func loadImageFromUrl(urlString: String, completion: (() -> ())? = nil) {
        image = nil
        
        self.urlStringForChecking = urlString
        
        let urlKey = urlString as NSString
        
        if let cachedItem = CachedImageView.imageCache.object(forKey: urlKey) {
            image = cachedItem.image
            completion?()
            return
        }
        
        guard let url = URL(string: urlString) else {
            if shouldUseEmptyImage {
                image = emptyImage
            }
            //load from local caching DB
            return
        }
        
        if(isServerReachable()) {
            URLSession.shared.dataTask(with: url, completionHandler: { [weak self] (data, response, error) in
                if error != nil {
                    return
                }
                
                DispatchQueue.main.async {
                    if let image = UIImage(data: data!) {
                        let cacheItem = DiscardableImageCacheItem(image: image)
                        CachedImageView.imageCache.setObject(cacheItem, forKey: urlKey)
                        
                        if urlString == self?.urlStringForChecking {
                            self?.image = image
                            _ = self?.save(fileName: urlString,andImage:image)
                            completion?()
                        }
                    }
                }
                
            }).resume()
        } else{
            if let image = self.load(fileName: urlString) {
                self.image = image
            }
            return
        }
    }
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func save(fileName:String, andImage:UIImage) -> String? {
        let savedFileName = fileName.components(separatedBy: "/")
        let fileURL = documentsUrl.appendingPathComponent(savedFileName[savedFileName.count - 1])
        if let imageData = UIImageJPEGRepresentation(andImage, 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
            return fileName // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }
    
    func load(fileName: String) -> UIImage? {
        var documentsUrl: URL {
            return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        }
        let savedFileName = fileName.components(separatedBy: "/")
        let fileURL = documentsUrl.appendingPathComponent(savedFileName[savedFileName.count - 1])
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            print("Error loading image : \(error)")
        }
        return nil
    }
    
}


