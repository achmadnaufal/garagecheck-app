import Foundation
import Combine

class CarDataService: ObservableObject {
    @Published var cars: [Car] = []
    @Published var isLoading = false
    @Published var error: String? = nil

    init() {
        loadLocalCars()
    }

    // MARK: - Load bundled JSON
    func loadLocalCars() {
        isLoading = true
        guard let url = Bundle.main.url(forResource: "indonesian_cars", withExtension: "json") else {
            // Fallback: load from project Data directory during development
            loadFromProjectData()
            return
        }
        decode(from: url)
    }

    private func loadFromProjectData() {
        // Attempt to load hardcoded fallback
        let fallback = Car.builtInCars
        DispatchQueue.main.async {
            self.cars = fallback
            self.isLoading = false
        }
    }

    private func decode(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([Car].self, from: data)
            DispatchQueue.main.async {
                self.cars = decoded.sorted { $0.make < $1.make }
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.error = "Failed to load car data: \(error.localizedDescription)"
                self.cars = Car.builtInCars
                self.isLoading = false
            }
        }
    }

    // MARK: - Search
    func search(query: String) -> [Car] {
        guard !query.isEmpty else { return cars }
        let q = query.lowercased()
        return cars.filter {
            $0.make.lowercased().contains(q) ||
            $0.model.lowercased().contains(q) ||
            $0.displayName.lowercased().contains(q)
        }
    }

    func cars(for make: String) -> [Car] {
        cars.filter { $0.make.lowercased() == make.lowercased() }
    }

    var makes: [String] {
        Array(Set(cars.map { $0.make })).sorted()
    }
}

// MARK: - Hardcoded fallback (mirrors indonesian_cars.json)
extension Car {
    static let builtInCars: [Car] = [
        Car(make: "Honda", model: "Brio RS", year: 2024, lengthMm: 3815, widthMm: 1680, heightMm: 1485, wheelbaseMm: 2405, segment: "City Car"),
        Car(make: "Toyota", model: "Avanza", year: 2024, lengthMm: 4395, widthMm: 1730, heightMm: 1695, wheelbaseMm: 2750, segment: "LMPV"),
        Car(make: "Daihatsu", model: "Xenia", year: 2024, lengthMm: 4395, widthMm: 1730, heightMm: 1690, wheelbaseMm: 2750, segment: "LMPV"),
        Car(make: "Mitsubishi", model: "Xpander", year: 2024, lengthMm: 4595, widthMm: 1750, heightMm: 1730, wheelbaseMm: 2775, segment: "MPV"),
        Car(make: "Toyota", model: "Rush", year: 2024, lengthMm: 4435, widthMm: 1695, heightMm: 1705, wheelbaseMm: 2685, segment: "SUV"),
        Car(make: "Toyota", model: "Kijang Innova Zenix", year: 2024, lengthMm: 4755, widthMm: 1850, heightMm: 1795, wheelbaseMm: 2850, segment: "Large MPV"),
        Car(make: "Honda", model: "HR-V", year: 2024, lengthMm: 4330, widthMm: 1790, heightMm: 1590, wheelbaseMm: 2610, segment: "Compact SUV"),
        Car(make: "Suzuki", model: "Ertiga", year: 2024, lengthMm: 4395, widthMm: 1735, heightMm: 1690, wheelbaseMm: 2740, segment: "MPV"),
        Car(make: "Daihatsu", model: "Sigra", year: 2024, lengthMm: 4070, widthMm: 1655, heightMm: 1600, wheelbaseMm: 2525, segment: "LCGC MPV"),
        Car(make: "Wuling", model: "Air ev", year: 2024, lengthMm: 2974, widthMm: 1505, heightMm: 1631, wheelbaseMm: 2010, segment: "City EV"),
        Car(make: "Toyota", model: "Calya", year: 2024, lengthMm: 4070, widthMm: 1655, heightMm: 1600, wheelbaseMm: 2525, segment: "LCGC MPV"),
        Car(make: "Honda", model: "Jazz", year: 2024, lengthMm: 4035, widthMm: 1694, heightMm: 1524, wheelbaseMm: 2530, segment: "Hatchback"),
        Car(make: "Honda", model: "City Hatchback RS", year: 2024, lengthMm: 4345, widthMm: 1748, heightMm: 1488, wheelbaseMm: 2600, segment: "Hatchback"),
        Car(make: "Hyundai", model: "Creta", year: 2024, lengthMm: 4300, widthMm: 1790, heightMm: 1635, wheelbaseMm: 2610, segment: "Compact SUV"),
        Car(make: "BYD", model: "Atto 3", year: 2024, lengthMm: 4455, widthMm: 1875, heightMm: 1615, wheelbaseMm: 2720, segment: "Electric SUV"),
        Car(make: "Suzuki", model: "Baleno", year: 2024, lengthMm: 3990, widthMm: 1745, heightMm: 1500, wheelbaseMm: 2520, segment: "Hatchback"),
        Car(make: "Mitsubishi", model: "Pajero Sport", year: 2024, lengthMm: 4785, widthMm: 1815, heightMm: 1785, wheelbaseMm: 2800, segment: "Large SUV"),
        Car(make: "Toyota", model: "Fortuner", year: 2024, lengthMm: 4795, widthMm: 1855, heightMm: 1835, wheelbaseMm: 2745, segment: "Large SUV"),
        Car(make: "Honda", model: "BR-V", year: 2024, lengthMm: 4455, widthMm: 1748, heightMm: 1684, wheelbaseMm: 2662, segment: "Compact SUV"),
        Car(make: "Wuling", model: "Almaz", year: 2024, lengthMm: 4655, widthMm: 1846, heightMm: 1760, wheelbaseMm: 2750, segment: "MPV"),
    ]
}
