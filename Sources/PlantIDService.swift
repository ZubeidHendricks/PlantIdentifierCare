import UIKit
import Vision

struct IDResult: Identifiable {
    let id = UUID()
    let label: String
    let confidence: Double
}

enum PlantIDError: Error { case badImage, noResults, notConfigured }

protocol PlantIdentifying {
    func identify(_ image: UIImage) async throws -> [IDResult]
}

/// On-device classification via Vision's built-in image classifier (~1000+
/// categories, including many plants, flowers and trees). Real and offline.
/// Species-level botanical ID is a Remote-service upgrade (CoreML/endpoint).
struct OnDeviceClassifier: PlantIdentifying {
    func identify(_ image: UIImage) async throws -> [IDResult] {
        guard let cg = image.normalizedUp().cgImage else { throw PlantIDError.badImage }
        return try await Task.detached(priority: .userInitiated) {
            let request = VNClassifyImageRequest()
            // Classification may be unavailable on Simulator; treat failure as no results.
            try? VNImageRequestHandler(cgImage: cg, options: [:]).perform([request])
            let observations = (request.results as? [VNClassificationObservation]) ?? []
            let results = observations
                .filter { $0.confidence > 0.05 }
                .prefix(8)
                .map { IDResult(label: $0.identifier.replacingOccurrences(of: "_", with: " ").capitalized,
                               confidence: Double($0.confidence)) }
            if results.isEmpty { throw PlantIDError.noResults }
            return Array(results)
        }.value
    }
}

/// Production botanical identifier (PlantNet/iNaturalist/your model). Wire here.
struct RemotePlantService: PlantIdentifying {
    let apiKey: String
    func identify(_ image: UIImage) async throws -> [IDResult] { throw PlantIDError.notConfigured }
}

enum CareGuide {
    /// Lightweight care tips keyed off the identified label's keywords.
    static func tips(for label: String) -> [String] {
        let l = label.lowercased()
        if l.contains("succulent") || l.contains("cactus") || l.contains("aloe") {
            return ["Bright, direct light", "Water sparingly — let soil dry fully", "Well-draining, sandy soil"]
        }
        if l.contains("fern") || l.contains("moss") {
            return ["Indirect light, no harsh sun", "Keep soil consistently moist", "Loves humidity — mist often"]
        }
        if l.contains("flower") || l.contains("orchid") || l.contains("rose") || l.contains("daisy") {
            return ["Plenty of bright light", "Water when top inch is dry", "Feed during the growing season"]
        }
        if l.contains("tree") || l.contains("palm") || l.contains("ficus") {
            return ["Bright, indirect light", "Water deeply, then let drain", "Rotate for even growth"]
        }
        return ["Bright, indirect light", "Water when the top inch of soil is dry", "Avoid cold drafts"]
    }
}

extension UIImage {
    func normalizedUp() -> UIImage {
        if imageOrientation == .up { return self }
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = scale
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
