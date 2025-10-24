import Foundation

struct Garage: Identifiable, Codable {
    var id: UUID
    var name: String
    /// Length in millimeters (front-to-back)
    var lengthMm: Double
    /// Width in millimeters (side-to-side)
    var widthMm: Double
    /// Height in millimeters (floor-to-ceiling)
    var heightMm: Double
    var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, createdAt
        case lengthMm = "length_mm"
        case widthMm = "width_mm"
        case heightMm = "height_mm"
    }

    init(
        id: UUID = UUID(),
        name: String = "My Garage",
        lengthMm: Double,
        widthMm: Double,
        heightMm: Double,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.lengthMm = lengthMm
        self.widthMm = widthMm
        self.heightMm = heightMm
        self.createdAt = createdAt
    }

    var lengthM: Double { lengthMm / 1000 }
    var widthM: Double  { widthMm  / 1000 }
    var heightM: Double { heightMm / 1000 }

    var displayDimensions: String {
        String(format: "%.1fm x %.1fm x %.1fm", lengthM, widthM, heightM)
    }
}

extension Garage {
    static let example = Garage(
        name: "Rumah Depok",
        lengthMm: 4800,
        widthMm: 2600,
        heightMm: 2400
    )
}
