[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fhigracehuang%2FSolicitReviewLibrary%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/higracehuang/SolicitReviewLibrary)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fhigracehuang%2FSolicitReviewLibrary%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/higracehuang/SolicitReviewLibrary)


# What is SolicitReviewLibrary?

SolicitReviewLibrary is a Swift package that manages the simple flow of the review solicitation process.

For any new version of your app, it will prompt the user to rate the app whenever it reaches the action threshold.

Currently, it is only enabled for iOS >= 14, and macOS >= 11. 

It supports multiple languages. The default language is English. Other languages are Simplified Chinese, Japanese, and German.

# Usage

## Review Prompt

1. Add `SolicitReviewLibrary` (https://github.com/higracehuang/SolicitReviewLibrary.git) to the Package Dependencies of your iOS or macOS app project.

2. Import `SolicitReviewLibrary`, and call `SolicitReviewLibrary.appInit()` in the App module.

For example, in the `ExampleApp`:

```
import SwiftUI
import SolicitReviewLibrary

@main
struct ExampleApp: App {
  init() {
    SolicitReviewLibrary.appInit() // 0) Init for the app
  }
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
```

3. Call `requestReview` on the UI where you would like to solicit reviews.

For example, after the user clicks the button 10 times, it will prompt to solicit a review.

```
import SwiftUI
import SolicitReviewLibrary

struct ContentView: View {
  @State private var buttonTapped = false
  
  let solicitReviewLibrary = SolicitReviewLibrary(checkpointCount: 10) // 1) Init
  
  var body: some View {
    VStack {
      Text("Button is \(buttonTapped ? "Tapped" : "Not Tapped")")
        .padding()
      
      Button(action: {
        self.buttonTapped.toggle()
        solicitReviewLibrary.requestReview() // 2) Prompt for review
        // let isPrompted = solicitReviewLibrary.requestReviewIfNecessary() // or use this to check if the review was prompted
      }) {
        Text("Tap Me!")
          .padding()
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(8)
      }
    }
  }
}
```

4. Build the app and test.

## Link to Review on App Store

Replace `idxxxxxxxxxxxx` with your app ID.

```
import SwiftUI
import SolicitReviewLibrary

struct ContentView: View {
    var body: some View {
        if let reviewURL = SolicitReviewLibrary.getReviewURL(appStoreId: "idxxxxxxxxxxxx") {
            Link(destination: reviewURL) {
                Text("Rate This App 🙏")
            }
        }
    }
}
```

It will direct to `https://apps.apple.com/in/app/app-name/idxxxxxxxxxxxx?action=write-review`

# Debug

In the Xcode console, look for debug lines with the tag `[SolicitReviewLibrary]` when testing.

```
[SolicitReviewLibrary] Reset engagementCounter to 0
[SolicitReviewLibrary] Reset appVersionForStorage to 1.0.2
[SolicitReviewLibrary] count:1 currentVersion:1.0.2 lastVersionPromptedForReview:1.0.3
[SolicitReviewLibrary] count:2 currentVersion:1.0.2 lastVersionPromptedForReview:1.0.3
```
