import UIKit

final class ImageLoader {

    static let shared = ImageLoader()
    private init() {}

    private let cache = NSCache<NSString, UIImage>()

    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Проверяем кэш
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }

        // Проверяем URL
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        // Загружаем изображение
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            var image: UIImage? = nil
            if let data = data {
                image = UIImage(data: data)
                if let image = image {
                    self.cache.setObject(image, forKey: urlString as NSString)
                }
            }
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
