import Foundation

struct Stock: Codable {
    let symbol: String
    let name: String
    let price: Double
    let change: Double
    let changePercent: Double
    let logo: String
    let type: String   

    enum CodingKeys: String, CodingKey {
        case symbol
        case name
        case price
        case change
        case changePercent
        case logo
        case type
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        change = try container.decode(Double.self, forKey: .change)
        changePercent = try container.decode(Double.self, forKey: .changePercent)
        logo = try container.decode(String.self, forKey: .logo)
        type = (try? container.decode(String.self, forKey: .type)) ?? "stock"
    }

    // init вручную для CoreData
    init(symbol: String, name: String, price: Double, change: Double, changePercent: Double, logo: String, type: String = "stock") {
        self.symbol = symbol
        self.name = name
        self.price = price
        self.change = change
        self.changePercent = changePercent
        self.logo = logo
        self.type = type
    }
}
