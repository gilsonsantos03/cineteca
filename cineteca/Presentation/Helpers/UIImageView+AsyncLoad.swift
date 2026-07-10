import UIKit

private var taskKey: UInt8 = 0

extension UIImageView {
    func loadImage(from url: URL?, placeholder: UIImage? = nil) {
        image = placeholder
        guard let url else { return }
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self?.image = image }
        }
        task.resume()
    }
}
