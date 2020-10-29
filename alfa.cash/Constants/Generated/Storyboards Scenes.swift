// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable sorted_imports
import Foundation
import UIKit

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Storyboard Scenes

// swiftlint:disable explicit_type_interface identifier_name line_length type_body_length type_name
internal enum StoryboardScene {
  internal enum AlfaCashLaunchScreen: StoryboardType {
    internal static let storyboardName = "AlfaCashLaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: AlfaCashLaunchScreen.self)

    internal static let alfaCashLaunchScreen = SceneType<UIKit.UIViewController>(storyboard: AlfaCashLaunchScreen.self, identifier: "AlfaCashLaunchScreen")
  }
  internal enum ExchangeFlow: StoryboardType {
    internal static let storyboardName = "ExchangeFlow"

    internal static let initialScene = InitialSceneType<AlfaCash.ExchangeViewController>(storyboard: ExchangeFlow.self)

    internal static let exchangeViewController = SceneType<AlfaCash.ExchangeViewController>(storyboard: ExchangeFlow.self, identifier: "ExchangeViewController")
  }
  internal enum HomePageFlow: StoryboardType {
    internal static let storyboardName = "HomePageFlow"

    internal static let initialScene = InitialSceneType<AlfaCash.HomePageViewController>(storyboard: HomePageFlow.self)

    internal static let walletsViewController = SceneType<AlfaCash.WalletsViewController>(storyboard: HomePageFlow.self, identifier: "WalletsViewController")
  }
  internal enum LaunchScreen: StoryboardType {
    internal static let storyboardName = "LaunchScreen"

    internal static let initialScene = InitialSceneType<UIKit.UIViewController>(storyboard: LaunchScreen.self)
  }
  internal enum OnboardingFlow: StoryboardType {
    internal static let storyboardName = "OnboardingFlow"

    internal static let initialScene = InitialSceneType<UIKit.UINavigationController>(storyboard: OnboardingFlow.self)

    internal static let onboardingViewController = SceneType<AlfaCash.OnboardingViewController>(storyboard: OnboardingFlow.self, identifier: "OnboardingViewController")
  }
  internal enum OptionsFlow: StoryboardType {
    internal static let storyboardName = "OptionsFlow"

    internal static let initialScene = InitialSceneType<AlfaCash.OptionsContainerViewController>(storyboard: OptionsFlow.self)

    internal static let legalViewController = SceneType<AlfaCash.LegalViewController>(storyboard: OptionsFlow.self, identifier: "LegalViewController")

    internal static let optionsContainerViewController = SceneType<AlfaCash.OptionsContainerViewController>(storyboard: OptionsFlow.self, identifier: "OptionsContainerViewController")

    internal static let passcodeViewController = SceneType<AlfaCash.PasscodeViewController>(storyboard: OptionsFlow.self, identifier: "PasscodeViewController")

    internal static let securityViewController = SceneType<AlfaCash.SecurityViewController>(storyboard: OptionsFlow.self, identifier: "SecurityViewController")

    internal static let termsAndPrivacyViewController = SceneType<AlfaCash.TermsAndPrivacyViewController>(storyboard: OptionsFlow.self, identifier: "TermsAndPrivacyViewController")

    internal static let usernameViewController = SceneType<AlfaCash.UsernameViewController>(storyboard: OptionsFlow.self, identifier: "UsernameViewController")
  }
  internal enum ReceiveFlow: StoryboardType {
    internal static let storyboardName = "ReceiveFlow"

    internal static let initialScene = InitialSceneType<AlfaCash.ReceiveViewController>(storyboard: ReceiveFlow.self)

    internal static let receiveViewController = SceneType<AlfaCash.ReceiveViewController>(storyboard: ReceiveFlow.self, identifier: "ReceiveViewController")
  }
  internal enum SendFlow: StoryboardType {
    internal static let storyboardName = "SendFlow"

    internal static let initialScene = InitialSceneType<AlfaCash.SendViewController>(storyboard: SendFlow.self)
  }
  internal enum SetLanguageFlow: StoryboardType {
    internal static let storyboardName = "SetLanguageFlow"

    internal static let initialScene = InitialSceneType<AlfaCash.SetLanguageViewController>(storyboard: SetLanguageFlow.self)
  }
  internal enum SettingsFlow: StoryboardType {
    internal static let storyboardName = "SettingsFlow"

    internal static let initialScene = InitialSceneType<AlfaCash.SettingsViewController>(storyboard: SettingsFlow.self)

    internal static let languagesViewController = SceneType<AlfaCash.LanguagesViewController>(storyboard: SettingsFlow.self, identifier: "LanguagesViewController")

    internal static let legalSettingsViewController = SceneType<AlfaCash.LegalSettingsViewController>(storyboard: SettingsFlow.self, identifier: "LegalSettingsViewController")

    internal static let recoveryPhraseViewController = SceneType<AlfaCash.RecoveryPhraseViewController>(storyboard: SettingsFlow.self, identifier: "RecoveryPhraseViewController")

    internal static let settingsViewController = SceneType<AlfaCash.SettingsViewController>(storyboard: SettingsFlow.self, identifier: "SettingsViewController")
  }
}
// swiftlint:enable explicit_type_interface identifier_name line_length type_body_length type_name

// MARK: - Implementation Details

internal protocol StoryboardType {
  static var storyboardName: String { get }
}

internal extension StoryboardType {
  static var storyboard: UIStoryboard {
    let name = self.storyboardName
    return UIStoryboard(name: name, bundle: Bundle(for: BundleToken.self))
  }
}

internal struct SceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type
  internal let identifier: String

  internal func instantiate() -> T {
    let identifier = self.identifier
    guard let controller = storyboard.storyboard.instantiateViewController(withIdentifier: identifier) as? T else {
      fatalError("ViewController '\(identifier)' is not of the expected class \(T.self).")
    }
    return controller
  }
}

internal struct InitialSceneType<T: UIViewController> {
  internal let storyboard: StoryboardType.Type

  internal func instantiate() -> T {
    guard let controller = storyboard.storyboard.instantiateInitialViewController() as? T else {
      fatalError("ViewController is not of the expected class \(T.self).")
    }
    return controller
  }
}

private final class BundleToken {}
