// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import StoreKit

#if os(iOS)
import UIKit
#endif


struct SettingKeys {
  static let engagementCounterKey = "EngagementCounter"
  static let lastVersionPromptedForReviewKey = "LastVersionPromptedForReview"
  static let appVersionForStorageKey = "appVersionForStorageKey"
}

public class SolicitReviewLibrary {

  private var checkpointCount: Int

  public init(checkpointCount: Int) {
    self.checkpointCount = checkpointCount
  }
  
  private func recordEngagement() -> Int {
    var count = UserDefaults.standard.integer(forKey: SettingKeys.engagementCounterKey)
    count += 1
    UserDefaults.standard.set(count, forKey: SettingKeys.engagementCounterKey)
    
    return count
  }
  
  private func shouldPrompt() -> Bool {
    let count = recordEngagement()
    let currentVersion = Bundle.main.releaseVersionNumber
    
    let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: SettingKeys.lastVersionPromptedForReviewKey) ?? ""
    
    Logger.log("count:\(count) currentVersion:\(currentVersion) lastVersionPromptedForReview:\(lastVersionPromptedForReview)")
    
    return count == checkpointCount && currentVersion != lastVersionPromptedForReview
  }
  

  public func requestReview() {
    if shouldPrompt() {
      Logger.log("Asking for review")
      askForReview(withHandler: showNativeReviewPrompt)
    }
  }

#if os(iOS)
  
  private func askForReview(withHandler handler: @escaping () -> Void) {
    let enjoyAppAlert = UIAlertController(
      title: NSLocalizedString("Do you enjoy \(Bundle.main.appName)?", comment: ""),
      message: NSLocalizedString("If you enjoy using \(Bundle.main.appName), we'd appreciate your feedback!", comment: ""),
      preferredStyle: .alert)
    
    let yesAction = UIAlertAction(title: NSLocalizedString("Yes. Rate \(Bundle.main.appName) now", comment: ""), style: .default) { _ in
      // If the user enjoys the app, call the provided handler
      handler()
    }
    
    let noAction = UIAlertAction(title: NSLocalizedString("No. Thanks", comment: ""), style: .default, handler: nil)
    
    enjoyAppAlert.addAction(noAction)
    enjoyAppAlert.addAction(yesAction)
    
    
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first?.rootViewController {
      rootViewController.present(enjoyAppAlert, animated: true, completion: nil)
    }
  }
  
  private func showNativeReviewPrompt() {
    DispatchQueue.main.async {
      if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
        SKStoreReviewController.requestReview(in: scene)
        UserDefaults.standard.set(Bundle.main.releaseVersionNumber, forKey: SettingKeys.lastVersionPromptedForReviewKey)
      }
    }
  }
  
#elseif os(macOS)
  private func askForReview(withHandler handler: @escaping () -> Void) {
    let alert = NSAlert()
    alert.messageText = NSLocalizedString("Do you enjoy \(Bundle.main.appName)?", comment: "")
    alert.informativeText = NSLocalizedString("If you enjoy using \(Bundle.main.appName), we'd appreciate your feedback!", comment: "")
    alert.addButton(withTitle: NSLocalizedString("Yes. Rate \(Bundle.main.appName) now", comment: ""))
    alert.addButton(withTitle: NSLocalizedString("No. Thanks", comment: ""))
    
    let modalResult = alert.runModal()
    if modalResult == .alertFirstButtonReturn {
      handler()
    }
  }
  
  private func showNativeReviewPrompt() {
    DispatchQueue.main.async {
      SKStoreReviewController.requestReview()
      UserDefaults.standard.set(Bundle.main.releaseVersionNumber, forKey: SettingKeys.lastVersionPromptedForReviewKey)
    }
  }
#endif
  
  public static func appInit() {
    let storedVersion = UserDefaults.standard.string(forKey: SettingKeys.appVersionForStorageKey) ?? ""
    
    let currentVersion = Bundle.main.releaseVersionNumber
    
    if storedVersion != currentVersion {
      // Perform actions to refresh fields or update as needed
      
      // Set the engagement counter to 0
      Logger.log("Reset engagementCounter to 0")
      UserDefaults.standard.set(0, forKey: SettingKeys.engagementCounterKey)
      
      // Finally, update stored version
      Logger.log("Reset appVersionForStorage to \(currentVersion)")
      UserDefaults.standard.set(currentVersion, forKey: SettingKeys.appVersionForStorageKey)
    } else {
      Logger.log("appVersionForStorage is up to date ✅")
    }
  }
  
  public static func getReviewURL(appStoreId: String) -> URL? {
    URL(string: "https://apps.apple.com/in/app/app-name/\(appStoreId)?action=write-review")
  }
}

