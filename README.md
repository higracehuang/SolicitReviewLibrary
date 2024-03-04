# Usage

1. Add `SolicitReviewLibrary` to your Package Dependencies of your iOS app project.

2. Import `SolicitReviewLibrary`, and call `SolicitReviewLibrary.appInit()` in the App module.

For example, in the `ExampleApp`:

```
import SwiftUI
import SolicitReviewLibrary

@main
struct ExampleApp: App {
  init() {
    SolicitReviewLibrary.initApp()
  }
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
```

3. Call `requestReview` on the UI where you would like to solicit reviews
