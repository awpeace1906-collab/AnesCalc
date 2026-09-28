// AnesthesiaCalc v2.0
// LocationReticleButton.swift — used by PatientInputView (next to the Altitude field)
// Purpose: one-shot CoreLocation altitude fetch, exposed as a crosshair/reticle
//          icon button (the "locate me" style used across mapping apps) that
//          sits next to the existing manual Altitude field. Populates the
//          field as an editable suggestion — never overwrites silently, and
//          never touches persistence/reset behavior already defined on
//          PatientModel (altitude stays intentionally un-persisted).
//
// Info.plist: NSLocationWhenInUseUsageDescription is set via
//   INFOPLIST_KEY_NSLocationWhenInUseUsageDescription in the target build settings.
//
// No network calls — CLLocation's altitude is GPS/barometer-fused on-device,
// so this keeps the app's existing "Offline Capable" behavior intact.

import SwiftUI
import CoreLocation

// MARK: - Reticle icon (SF Symbol — reliable layout in all iOS versions)

// MARK: - One-shot location fetcher

final class AltitudeLocationFetcher: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var isFetching = false
    @Published var lastError: String?

    private var completion: ((Double) -> Void)?

    func requestAltitude(completion: @escaping (Double) -> Void) {
        self.completion = completion
        lastError = nil
        isFetching = true
        manager.delegate = self

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            isFetching = false
            lastError = "Location access denied — enable it in Settings, or enter altitude manually."
        @unknown default:
            isFetching = false
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            isFetching = false
            lastError = "Location access denied — enable it in Settings, or enter altitude manually."
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        isFetching = false
        guard let loc = locations.last else { return }
        // loc.altitude is meters above sea level, GPS+barometer fused on
        // modern devices. Round to a clinically sensible precision.
        completion?(loc.altitude.rounded())
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isFetching = false
        lastError = "Couldn't get a location fix — enter altitude manually."
    }
}

// MARK: - Drop-in button, sits next to the existing Altitude PlaceholderNumberField

struct AltitudeLocationButton: View {
    @Binding var altitude: Double
    @Binding var touchedFields: Set<String>
    var accentColor: Color

    @StateObject private var fetcher = AltitudeLocationFetcher()
    @State private var showError = false

    var body: some View {
        Button(action: fetchAltitude) {
            if fetcher.isFetching {
                ProgressView()
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: "location.circle")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(accentColor)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 36, height: 44)
        .contentShape(Rectangle())
        .disabled(fetcher.isFetching)
        .alert("Location Unavailable", isPresented: $showError, presenting: fetcher.lastError) { _ in
            Button("OK", role: .cancel) {}
        } message: { message in
            Text(message)
        }
    }

    private func fetchAltitude() {
        fetcher.requestAltitude { meters in
            altitude = meters
            touchedFields.insert(AppField.altitude.rawValue.description)
            if fetcher.lastError != nil { showError = true }
        }
        // Surface auth-denied / fetch-failure after the async callback settles.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if fetcher.lastError != nil { showError = true }
        }
    }
}
