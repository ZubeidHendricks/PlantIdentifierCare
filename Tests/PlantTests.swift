import XCTest
import UIKit
// PlantIDService.swift compiled into this test target.

final class PlantTests: XCTestCase {
    private func image(_ s: CGFloat = 400) -> UIImage {
        let f = UIGraphicsImageRendererFormat.default(); f.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: s, height: s), format: f).image { c in
            UIColor.systemGreen.setFill(); c.fill(CGRect(x: 0, y: 0, width: s, height: s))
        }
    }

    func testCareGuideByCategory() {
        XCTAssertEqual(CareGuide.tips(for: "Boston Fern").count, 3)
        XCTAssertFalse(CareGuide.tips(for: "Cactus").isEmpty)
        XCTAssertFalse(CareGuide.tips(for: "Some Unknown Plant").isEmpty)  // generic fallback
    }

    func testIdentifyRunsGracefully() async {
        do {
            let results = try await OnDeviceClassifier().identify(image())
            XCTAssertFalse(results.isEmpty)
        } catch PlantIDError.noResults {
            // acceptable for a flat synthetic image
        } catch {
            XCTFail("unexpected error: \(error)")
        }
    }
}
