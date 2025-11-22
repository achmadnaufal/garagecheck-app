import XCTest
@testable import GarageCheck

final class FitCalculationServiceTests: XCTestCase {

    // MARK: - Helper factories

    private func garage(lengthMm: Double, widthMm: Double, heightMm: Double) -> Garage {
        Garage(name: "Test Garage", lengthMm: lengthMm, widthMm: widthMm, heightMm: heightMm)
    }

    private func car(lengthMm: Double, widthMm: Double, heightMm: Double) -> Car {
        Car(id: UUID(), make: "Test", model: "Car", year: 2024,
            lengthMm: lengthMm, widthMm: widthMm, heightMm: heightMm,
            wheelbaseMm: 2500, segment: "Test")
    }

    // MARK: - Test: car fits comfortably (Honda Brio RS in large garage)

    func testBrioFitsInLargeGarage() {
        // Brio RS: 3815 x 1680 x 1485 mm
        // Large garage: 5500 x 2800 x 2500 mm
        let g = garage(lengthMm: 5500, widthMm: 2800, heightMm: 2500)
        let c = car(lengthMm: 3815, widthMm: 1680, heightMm: 1485)
        let result = FitCalculationService.calculate(garage: g, car: c)

        XCTAssertEqual(result.status, .fits, "Brio RS should fit comfortably in 5.5m garage")
        XCTAssertGreaterThanOrEqual(result.lengthMarginMm, 300, "Length margin should be >= 300mm")
        XCTAssertGreaterThanOrEqual(result.widthMarginMm, 300, "Width margin should be >= 300mm")
        XCTAssertGreaterThan(result.heightMarginMm, 0, "Height margin should be positive")
    }

    // MARK: - Test: car doesn't fit (Toyota Fortuner in tiny garage)

    func testFortunerDoesNotFitInTinyGarage() {
        // Fortuner: 4795 x 1855 x 1835 mm
        // Tiny garage: 4000 x 2000 x 2100 mm
        let g = garage(lengthMm: 4000, widthMm: 2000, heightMm: 2100)
        let c = car(lengthMm: 4795, widthMm: 1855, heightMm: 1835)
        let result = FitCalculationService.calculate(garage: g, car: c)

        XCTAssertEqual(result.status, .doesNotFit, "Fortuner should not fit in tiny 4m garage")
        XCTAssertLessThan(result.lengthMarginMm, 0, "Length margin should be negative")
        XCTAssertFalse(FitCalculationService.canPhysicallyFit(garage: g, car: c))
    }

    // MARK: - Test: tight fit edge case

    func testTightFitEdgeCase() {
        // Car that leaves exactly 150mm width and 200mm length clearance → Tight
        let g = garage(lengthMm: 5000, widthMm: 2400, heightMm: 2500)
        let c = car(lengthMm: 4800, widthMm: 2250, heightMm: 1800)
        // lengthMargin = 200, widthMargin = 150 → min = 150, which is in [100, 300) → .tight
        let result = FitCalculationService.calculate(garage: g, car: c)

        XCTAssertEqual(result.status, .tight, "Should be a tight fit with ~150mm margin")
        XCTAssertEqual(result.widthMarginMm, 150)
        XCTAssertEqual(result.lengthMarginMm, 200)
    }

    // MARK: - Test: height doesn't fit

    func testHeightDoesNotFit() {
        // Car height exceeds garage height
        let g = garage(lengthMm: 6000, widthMm: 3000, heightMm: 1800)
        let c = car(lengthMm: 4500, widthMm: 1800, heightMm: 1900)
        let result = FitCalculationService.calculate(garage: g, car: c)

        // Floor fit is comfortable, but height fails
        XCTAssertLessThan(result.heightMarginMm, 0, "Height margin should be negative")
        XCTAssertFalse(
            FitCalculationService.canPhysicallyFit(garage: g, car: c),
            "canPhysicallyFit should return false when car is too tall"
        )
        // fitStatus only checks length/width so status may be .fits — height is stored separately
        XCTAssertEqual(result.heightMarginMm, -100)
    }

    // MARK: - Test: exact match (0 cm margin)

    func testExactMatch_ZeroMargin() {
        // Car and garage are exactly the same size → 0mm margin on all axes
        let dims: Double = 4000
        let g = garage(lengthMm: dims, widthMm: dims, heightMm: dims)
        let c = car(lengthMm: dims, widthMm: dims, heightMm: dims)
        let result = FitCalculationService.calculate(garage: g, car: c)

        XCTAssertEqual(result.lengthMarginMm, 0)
        XCTAssertEqual(result.widthMarginMm, 0)
        XCTAssertEqual(result.heightMarginMm, 0)
        XCTAssertEqual(result.status, .tooTight, "0mm margin should be tooTight (in [0, 100))")
        // Should physically fit (margins not negative)
        XCTAssertTrue(FitCalculationService.canPhysicallyFit(garage: g, car: c))
    }

    // MARK: - Additional: fitStatus pure function

    func testFitStatusComfortable() {
        let status = FitCalculationService.fitStatus(lengthMargin: 500, widthMargin: 400)
        XCTAssertEqual(status, .fits)
    }

    func testFitStatusNegativeMargin() {
        let status = FitCalculationService.fitStatus(lengthMargin: -1, widthMargin: 500)
        XCTAssertEqual(status, .doesNotFit)
    }

    func testFitStatusBothNegative() {
        let status = FitCalculationService.fitStatus(lengthMargin: -100, widthMargin: -50)
        XCTAssertEqual(status, .doesNotFit)
    }

    func testFitStatusTooTight() {
        let status = FitCalculationService.fitStatus(lengthMargin: 50, widthMargin: 90)
        XCTAssertEqual(status, .tooTight)
    }
}
