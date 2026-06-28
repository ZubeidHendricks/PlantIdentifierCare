import SwiftUI
import PhotosUI
import AppFactoryKit

// Plant Identifier & Care — snap or pick a photo, identify it on-device, and get
// care tips. Identification uses Vision's built-in classifier; species-level
// botanical ID is wired behind RemotePlantService (Pro).
struct ContentView: View {
    @EnvironmentObject private var factory: AppFactory
    private let service: PlantIdentifying = OnDeviceClassifier()

    @State private var pickerItem: PhotosPickerItem?
    @State private var image: UIImage?
    @State private var results: [IDResult] = []
    @State private var isProcessing = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    preview
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label(image == nil ? "Choose Photo" : "Choose Another", systemImage: "photo")
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.bordered)

                    if let top = results.first {
                        resultCard(top)
                    }
                    if let errorText { Text(errorText).font(.footnote).foregroundStyle(.red) }
                }
                .padding(20)
            }
            .navigationTitle("Plant ID")
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await load(item) }
        }
    }

    private var preview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18).fill(.quaternary)
            if let image {
                Image(uiImage: image).resizable().scaledToFit().clipShape(RoundedRectangle(cornerRadius: 18))
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "leaf").font(.system(size: 54)).foregroundStyle(.green)
                    Text("Pick a plant photo to identify").foregroundStyle(.secondary)
                }
            }
            if isProcessing { ProgressView().controlSize(.large) }
        }
        .frame(height: 320)
    }

    private func resultCard(_ top: IDResult) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(top.label).font(.title3.bold())
                Spacer()
                Text("\(Int(top.confidence * 100))%").font(.subheadline).foregroundStyle(.secondary)
            }

            // Alternative guesses (premium unlocks the full list + detail).
            if results.count > 1 {
                let extra = factory.subscriptions.isSubscribed ? Array(results.dropFirst()) : Array(results.dropFirst().prefix(1))
                ForEach(extra) { r in
                    HStack {
                        Text(r.label).font(.callout)
                        Spacer()
                        Text("\(Int(r.confidence * 100))%").font(.caption).foregroundStyle(.secondary)
                    }
                }
                if !factory.subscriptions.isSubscribed {
                    Button("See all matches (Pro)") { factory.presentPaywall(placement: "all_matches") }
                        .font(.footnote)
                }
            }

            Divider()
            Text("Care").font(.headline)
            ForEach(CareGuide.tips(for: top.label), id: \.self) { tip in
                Label(tip, systemImage: "drop").font(.callout)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(.quaternary.opacity(0.5)))
    }

    private func load(_ item: PhotosPickerItem) async {
        errorText = nil; results = []
        guard let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) else {
            errorText = "Couldn't load that photo."; return
        }
        image = img
        isProcessing = true
        defer { isProcessing = false }
        do {
            results = try await service.identify(img)
        } catch PlantIDError.noResults {
            errorText = "Couldn't identify that — try a closer, clearer shot."
        } catch {
            errorText = "Identification failed."
        }
    }
}
