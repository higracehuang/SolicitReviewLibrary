# What is SolicitReviewLibrary?

SolicitReviewLibrary is a Swift package that manages the simple flow of the review solicitation process.

For any new version of your app, it will prompt the user to rate the app whenever it reaches the action threshold.

Currently, it is only enabled for iOS >= 14.

# Usage

1. Add `SolicitReviewLibrary` (https://github.com/higracehuang/SolicitReviewLibrary.git) to the Package Dependencies of your iOS app project.

2. Import `SolicitReviewLibrary`, and call `SolicitReviewLibrary.appInit()` in the App module.

For example, in the `ExampleApp`:

```
import SwiftUI
import SolicitReviewLibrary

@main
struct ExampleApp: App {
  init() {
    SolicitReviewLibrary.appInit()
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
  
  let solicitReviewLibrary = SolicitReviewLibrary(checkpointCount: 10)
  
  var body: some View {
    VStack {
      Text("Button is \(buttonTapped ? "Tapped" : "Not Tapped")")
        .padding()
      
      Button(action: {
        self.buttonTapped.toggle()
        solicitReviewLibrary.requestReview()
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


# Debug

In the Xcode console, look for debug lines with the tag `[SolicitReviewLibrary]` when testing.

```
[SolicitReviewLibrary] Reset engagementCounter to 0
[SolicitReviewLibrary] Reset appVersionForStorage to 1.0.2
[SolicitReviewLibrary] count:1 currentVersion:1.0.2 lastVersionPromptedForReview:1.0.3
[SolicitReviewLibrary] count:2 currentVersion:1.0.2 lastVersionPromptedForReview:1.0.3
```
