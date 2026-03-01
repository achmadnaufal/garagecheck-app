import Foundation

struct Car: Identifiable, Codable, Hashable {
    var id: UUID
    var make: String
    var model: String
    var year: Int
    // All dimensions in millimeters
    var lengthMm: Double
    var widthMm: Double
    var heightMm: Double
    var wheelbaseMm: Double?
    var segment: String

    enum CodingKeys: String, CodingKey {
        case id, make, model, year, segment
        case lengthMm = "length_mm"
        case widthMm = "width_mm"
        case heightMm = "height_mm"
        case wheelbaseMm = "wheelbase_mm"
    }

    init(
        id: UUID = UUID(),
        make: String,
        model: String,
        year: Int,
        lengthMm: Double,
        widthMm: Double,
        heightMm: Double,
        wheelbaseMm: Double? = nil,
        segment: String = ""
    ) {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.lengthMm = lengthMm
        self.widthMm = widthMm
        self.heightMm = heightMm
        self.wheelbaseMm = wheelbaseMm
        self.segment = segment
    }

    var displayName: String { "\(make) \(model)" }
    var fullDisplayName: String { "\(year) \(make) \(model)" }

    var lengthM: Double { lengthMm / 1000 }
    var widthM: Double { widthMm / 1000 }
    var heightM: Double { heightMm / 1000 }

    var displayDimensions: String {
        String(format: "L: %.0fmm x W: %.0fmm x H: %.0fmm", lengthMm, widthMm, heightMm)
    }
}

extension Car {
    static let example = Car(
        make: "Toyota",
        model: "Avanza",
        year: 2024,
        lengthMm: 4395,
        widthMm: 1730,
        heightMm: 1695,
        wheelbaseMm: 2750,
        segment: "LMPV"
    )
}
