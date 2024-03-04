import Foundation

extension Bundle {
  var releaseVersionNumber: String {
    return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
  }
  var buildVersionNumber: String {
    return infoDictionary?["CFBundleVersion"] as? String ?? ""
  }
  
  var appName: String {
    guard let appName = infoDictionary?["CFBundleDisplayName"] as? String else {
      fatalError("App name not found in Info.plist.")
    }
    return appName
  }
}

