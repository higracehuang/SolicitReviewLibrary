// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import StoreKit

#if os(iOS)
import UIKit
#endif

import SwiftUI

struct SettingKeys {
    static let engagementCounterKey = "EngagementCounter"
    static let lastVersionPromptedForReviewKey = "LastVersionPromptedForReview"
    static let appVersionForStorageKey = "appVersionForStorageKey"
}

struct PromptStrings {
    static let title = String(format: NSLocalizedString("Are you enjoying %@?", bundle: .moduleBundle, comment: ""), Bundle.main.appName)
    static let message = NSLocalizedString("Please let us know what you think!", bundle: .moduleBundle, comment: "")
    static let yesButton = NSLocalizedString("Love it! 🥰", bundle: .moduleBundle, comment: "")
    static let noButton = NSLocalizedString("Not really", bundle: .moduleBundle, comment: "")
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
        Logger.log("count: \(count)")
        return count == checkpointCount && !hasPromptYet()
    }
    
    public func requestReview() {
        if shouldPrompt() {
            Logger.log("Asking for review")
            askForReview(withHandler: showNativeReviewPrompt)
        }
    }

    public func debugResetEngagementCounter() {
        UserDefaults.standard.set(0, forKey: SettingKeys.engagementCounterKey)
    }

#if os(iOS)
    
    private func askForReview(withHandler handler: @escaping () -> Void) {
        let alert = UIAlertController(
            title: PromptStrings.title,
            message: PromptStrings.message,
            preferredStyle: .alert)
        
        let noAction = UIAlertAction(title: PromptStrings.noButton, style: .default, handler: nil)
        let yesAction = UIAlertAction(title: PromptStrings.yesButton, style: .default) { _ in
            handler()
        }
        
        alert.addAction(noAction)
        alert.addAction(yesAction)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        } else {
            Logger.log("No root view controller found")
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
        alert.messageText = PromptStrings.title
        alert.informativeText = PromptStrings.message
        alert.addButton(withTitle: PromptStrings.yesButton)
        alert.addButton(withTitle: PromptStrings.noButton)
        alert.buttons.first?.keyEquivalent = "\r"
        
        if alert.runModal() == .alertFirstButtonReturn {
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
            Logger.log("Reset engagementCounter to 0")
            UserDefaults.standard.set(0, forKey: SettingKeys.engagementCounterKey)
            
            Logger.log("Reset appVersionForStorage to \(currentVersion)")
            UserDefaults.standard.set(currentVersion, forKey: SettingKeys.appVersionForStorageKey)
        } else {
            Logger.log("appVersionForStorage is up to date ✅")
        }
    }
    
    public static func getReviewURL(appStoreId: String) -> URL? {
        URL(string: "https://apps.apple.com/in/app/app-name/\(appStoreId)?action=write-review")
    }

    public static func getShareURL(appStoreId: String) -> URL? {
        URL(string: "https://apps.apple.com/app/\(appStoreId)")
    }

    public func hasPromptYet() -> Bool {
        let lastVersionPrompted = UserDefaults.standard.string(forKey: SettingKeys.lastVersionPromptedForReviewKey) ?? ""
        let currentVersion = Bundle.main.releaseVersionNumber
        Logger.log("currentVersion:\(currentVersion) lastVersionPrompted:\(lastVersionPrompted)")
        return lastVersionPrompted == currentVersion
    }

    public static func actionShareApp(appStoreId: String) {
      let appURL = getShareURL(appStoreId: appStoreId)!
      let shareText = "Check out this amazing app: \(Bundle.main.appName)! Download it here: \(appURL)"
      let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
      
      if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
         let rootVC = windowScene.windows.first?.rootViewController {
        rootVC.present(activityVC, animated: true, completion: nil)
      }
    }
}
