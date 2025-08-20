import CoreData
import UIKit

final class CoreDataManager {

    static let shared = CoreDataManager()
    private init() {}

    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TestLuxury") // имя модели .xcdatamodeld
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Save Favourite
    func saveFavourite(stock: Stock) {
        guard !isFavourite(symbol: stock.symbol) else { return }

        let favourite = FavouriteStock(context: context)
        favourite.symbol = stock.symbol
        favourite.name = stock.name
        favourite.price = stock.price
        favourite.change = stock.change
        favourite.changePercent = stock.changePercent
        favourite.logo = stock.logo
        favourite.type = stock.type

        saveContext()
    }

    // MARK: - Delete Favourite
    func deleteFavourite(symbol: String) {
        let request: NSFetchRequest<FavouriteStock> = FavouriteStock.fetchRequest()
        request.predicate = NSPredicate(format: "symbol == %@", symbol)

        if let results = try? context.fetch(request) {
            for object in results {
                context.delete(object)
            }
            saveContext()
        }
    }

    // MARK: - Check Favourite
    func isFavourite(symbol: String) -> Bool {
        let request: NSFetchRequest<FavouriteStock> = FavouriteStock.fetchRequest()
        request.predicate = NSPredicate(format: "symbol == %@", symbol)
        if let count = try? context.count(for: request) {
            return count > 0
        }
        return false
    }

    // MARK: - Get All Favourites
    func getAllFavourites() -> [Stock] {
        let request: NSFetchRequest<FavouriteStock> = FavouriteStock.fetchRequest()
        if let favourites = try? context.fetch(request) {
            return favourites.map { fav in
                Stock(
                    symbol: fav.symbol ?? "",
                    name: fav.name ?? "",   
                    price: fav.price,
                    change: fav.change,
                    changePercent: fav.changePercent,
                    logo: fav.logo ?? "",
                    type: "stock"
                )
            }
        }
        return []
    }

    // MARK: - Save Context
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения Core Data: \(error)")
            }
        }
    }
}

// MARK: - Search History
extension CoreDataManager {
    func saveSearchQuery(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        request.predicate = NSPredicate(format: "query == %@", trimmed)

        if let existing = try? context.fetch(request), let item = existing.first {
            // если уже есть — обновляем дату
            item.date = Date()
        } else {
            // создаём новый объект
            let history = SearchHistory(context: context)
            history.query = trimmed
            history.date = Date()
        }

        saveContext()
        enforceHistoryLimit(20) // оставляем только последние 20
    }

    func getSearchHistory(limit: Int = 20) -> [String] {
        let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = limit

        if let results = try? context.fetch(request) {
            return results.compactMap { $0.query }
        }
        return []
    }

    func clearSearchHistory() {
        let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        if let results = try? context.fetch(request) {
            for obj in results {
                context.delete(obj)
            }
            saveContext()
        }
    }

    /// Убираем записи, если превысили лимит
    private func enforceHistoryLimit(_ limit: Int) {
        let request: NSFetchRequest<SearchHistory> = SearchHistory.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        if let results = try? context.fetch(request), results.count > limit {
            for item in results.suffix(from: limit) {
                context.delete(item)
            }
            saveContext()
        }
    }
}
