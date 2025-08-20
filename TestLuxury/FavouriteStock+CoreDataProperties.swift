import Foundation
import CoreData

extension FavouriteStock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavouriteStock> {
        return NSFetchRequest<FavouriteStock>(entityName: "FavouriteStock")
    }

    @NSManaged public var symbol: String?
    @NSManaged public var companyName: String?
    @NSManaged public var price: Double
    @NSManaged public var change: Double
    @NSManaged public var logoURL: String?
}

extension FavouriteStock : Identifiable {
    
}
