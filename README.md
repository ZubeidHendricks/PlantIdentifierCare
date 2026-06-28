# PlantIdentifierCare

Generated from niche `plant-id` (AI Vision, tier S, score 84).

**Utility:** Identify plants from a photo + care reminders
**Primary ASO keyword:** `plant identifier`
**Also target:** `identify plant`, `plant care`, `plant disease`, `what plant`
**Paywall hook:** Unlimited IDs, disease diagnosis, care schedule

> PictureThis does 8-figures. Vision model + care DB. Recurring care = retention.

## Build it

```bash
brew install xcodegen        # once
cd PlantIdentifierCare
xcodegen generate
open PlantIdentifierCare.xcodeproj
```

The app runs immediately on a MockPurchaseProvider (real paywall UI, fake
purchases). To go live:

1. Replace `revenueCatKey` in `Sources/App.swift` with your RevenueCat key.
2. In App Store Connect create products `plant-id_yearly` and `plant-id_weekly`,
   map them into a RevenueCat offering, entitlement id `premium`.
3. Build the real feature in `Sources/ContentView.swift`.
4. **Guideline 4.3:** make the function, UI, screenshots and keywords genuinely
   distinct from any sibling app. Re-niche, never reskin.

Bundle id: `com.zubeid.plantid`

## Ship to TestFlight

This app ships with a Fastlane lane + GitHub Actions workflow. One-time account
setup (API key, signing) is documented in the kit's `Tools/appgen/DEPLOYMENT.md`.
Once your GitHub secrets are set, trigger the **TestFlight** workflow (or push a
`v*` tag), or run locally:

```bash
bundle install
bundle exec fastlane beta
```
