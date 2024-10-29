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

  let promptTitle = NSLocalizedString("Are you enjoying \(Bundle.main.appName)?", comment: "")
  let promptMessage = NSLocalizedString("Please let us know what you think!", comment: "")
  let yesButtonTitle = NSLocalizedString("Love it! 🥰", comment: "")
  let noButtonTitle = NSLocalizedString("Not really", comment: "")

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
      title: promptTitle,
      message: promptMessage,
      preferredStyle: .alert)
    
    let noAction = UIAlertAction(title: noButtonTitle, style: .default, handler: nil)
    let yesAction = UIAlertAction(title: yesButtonTitle, style: .default) { _ in
      // If the user enjoys the app, call the provided handler
      handler()
    }
    
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
    alert.messageText = promptTitle
    alert.informativeText = promptMessage
    alert.addButton(withTitle: noButtonTitle)
    alert.addButton(withTitle: yesButtonTitle)
    
    let modalResult = alert.runModal()
    if modalResult == .alertSecondButtonReturn {
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

