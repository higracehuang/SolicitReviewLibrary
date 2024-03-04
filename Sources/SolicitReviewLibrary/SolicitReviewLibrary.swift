// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import UIKit
import StoreKit

struct SettingKeys {
  static let engagementCounterKey = "EngagementCounter"
  static let lastVersionPromptedForReviewKey = "LastVersionPromptedForReview"
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
  
  func requestReview() {
    if shouldPrompt() {
      Logger.log("Asking for review")
      askForReview(withHandler: showNativeReviewPrompt)
    }
  }
  
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
}

