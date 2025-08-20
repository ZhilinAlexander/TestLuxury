import Foundation

final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = "https://mustdev.ru/api/stocks.json"

    func fetchStocks(completion: @escaping (Result<[Stock], Error>) -> Void) {
        guard let url = URL(string: baseURL) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { return }
            do {
                let stocks = try JSONDecoder().decode([Stock].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(stocks))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
