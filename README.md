# Drummit

Drummit is an iOS app that detects and identifies drum equipment in photos. The app sends images to a small Go server, which calls Gemini's API to recognize the gear and returns the results to the app.

```
ios/      SwiftUI iOS app (Xcode project)
server/   Go server that talks to the Gemini API
```

## Requirements

- A Mac with [Xcode](https://developer.apple.com/xcode/) installed (for the iOS app)
- [Go](https://go.dev/dl/) (for the server)
- A [Gemini API key](https://aistudio.google.com/apikey)

## Running the Go server

1. **Install Go** if you haven't already. Download it from [go.dev/dl](https://go.dev/dl/) and follow the [installation docs](https://go.dev/doc/install) if you need help getting set up. Check that it worked with:

   ```sh
   go version
   ```

2. **Set your Gemini API key.** A Gemini API key is required. From the `server` directory, run:

   ```sh
   cd server
   export GEMINI_API_KEY={your_key}
   ```

   This only lasts for the current terminal session, so run it again in new terminal windows.

3. **Start the server:**

   ```sh
   go run .
   ```

   The server listens on port **8080** by default.

## Running the iOS app

1. **Create a secrets file.** In `ios/Config/`, create a `Secrets.xcconfig` file with an `API_BASE_URL` variable. Use `Secrets.example.xcconfig` as a reference for the format:

   ```
   API_BASE_URL = http:/$()/localhost:8080
   ```

   (The `$()` keeps Xcode from treating `//` as the start of a comment.)

2. **Pick the right host:**
   - **Simulator or Xcode Preview:** `localhost` works fine.
   - **Physical device:** use your Mac's local IP address instead of `localhost`, e.g. `http:/$()/192.168.1.20:8080`. Your phone and Mac need to be on the same network.

3. **Match the port.** Make sure the port in `API_BASE_URL` matches the port the Go server is running on (8080 by default).

4. Open `ios/Drummit.xcodeproj` in Xcode and run the app.

5. **Allow local network access.** The first time you scan an image, the request to the Go server will fail immediately and an alert will ask to let the app find devices on your local network. You must accept this alert for the app to reach the server locally. Then scan again.

## A note on timeouts

Both the server and the iOS app give requests a 2-minute timeout. This is mostly for development and testing. Depending on your connection and Gemini plan, responses can take a while.
