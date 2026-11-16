//
//  DrummitAppCheckProviderFactory.swift
//  Drummit
//

import FirebaseAppCheck
import FirebaseCore

/// Tells Firebase App Check how to prove this app is genuine.
///
/// - Simulator: the debug provider. App Attest needs real Apple hardware, so
///   the simulator instead uses a debug token you register in the Firebase
///   console.
/// - Device: App Attest, which asks Apple to confirm this is an unmodified
///   build of the app on a real device.
final class DrummitAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        #if targetEnvironment(simulator)
        return AppCheckDebugProvider(app: app)
        #else
        return AppAttestProvider(app: app)
        #endif
    }
}
