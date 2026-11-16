//
//  AppCheckTokenProvider.swift
//  Drummit
//

import FirebaseAppCheck

/// Something that can supply an App Check token for a request.
///
/// HttpClient depends on this protocol rather than on Firebase directly, so
/// previews and tests can pass a fake (or nil) instead of a real Firebase setup.
protocol AppCheckTokenProvider {
    func token() async throws -> String
}

/// The real provider, backed by the Firebase App Check SDK.
struct FirebaseAppCheckTokenProvider: AppCheckTokenProvider {
    func token() async throws -> String {
        // forcingRefresh: false returns the cached token while it's still
        // valid, and only contacts Firebase when it needs a new one.
        try await AppCheck.appCheck().token(forcingRefresh: false).token
    }
}
