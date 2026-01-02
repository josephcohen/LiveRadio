import Foundation

@MainActor
class RadioStore: ObservableObject {
    @Published var categories: [RadioCategory] = []

    private let saveKey = "LiveRadioCategories"

    init() {
        loadCategories()
    }

    // MARK: - Persistence

    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([RadioCategory].self, from: data) {
            categories = decoded
        } else {
            categories = DefaultRadioStations.categories
            saveCategories()
        }
    }

    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }

    // MARK: - Category Access

    func category(for id: String) -> RadioCategory? {
        categories.first { $0.id == id }
    }

    func stations(for categoryId: String) -> [RadioStation] {
        category(for: categoryId)?.stations ?? []
    }

    // MARK: - Category Management

    func addCategory(name: String, shortName: String, icon: String) {
        let category = RadioCategory(name: name, shortName: shortName, icon: icon)
        categories.append(category)
        saveCategories()
    }

    func updateCategory(_ category: RadioCategory) {
        if let index = categories.firstIndex(where: { $0.id == category.id }) {
            categories[index] = category
            saveCategories()
        }
    }

    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        categories.remove(at: index)
        saveCategories()
    }

    func moveCategory(from: IndexSet, to: Int) {
        categories.move(fromOffsets: from, toOffset: to)
        saveCategories()
    }

    // MARK: - Station Management

    func addStation(to categoryId: String, station: RadioStation) {
        if let index = categories.firstIndex(where: { $0.id == categoryId }) {
            categories[index].stations.append(station)
            saveCategories()
        }
    }

    func addStation(_ station: RadioStation, toCategoryId categoryId: String) {
        addStation(to: categoryId, station: station)
    }

    func updateStation(in categoryId: String, station: RadioStation) {
        if let catIndex = categories.firstIndex(where: { $0.id == categoryId }),
           let stationIndex = categories[catIndex].stations.firstIndex(where: { $0.id == station.id }) {
            categories[catIndex].stations[stationIndex] = station
            saveCategories()
        }
    }

    func deleteStation(from categoryId: String, at index: Int) {
        if let catIndex = categories.firstIndex(where: { $0.id == categoryId }) {
            categories[catIndex].stations.remove(at: index)
            saveCategories()
        }
    }

    func moveStation(in categoryId: String, from: IndexSet, to: Int) {
        if let catIndex = categories.firstIndex(where: { $0.id == categoryId }) {
            categories[catIndex].stations.move(fromOffsets: from, toOffset: to)
            saveCategories()
        }
    }

    // MARK: - Reset

    func resetToDefaults() {
        categories = DefaultRadioStations.categories
        saveCategories()
    }
}
