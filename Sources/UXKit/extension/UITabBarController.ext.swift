// © Sybl

import UIKit

extension UITabBarController {

  /// Makes the tab bar background transparent.
  public func makeTabBarBackgroundTransparent() {
    if #available(iOS 13.0, *) {
      let appearance = tabBar.standardAppearance.copy()
      appearance.configureWithTransparentBackground()
      tabBar.standardAppearance = appearance
    }
    else {
      tabBar.shadowImage = UIImage()
      tabBar.backgroundImage = UIImage()
    }

    tabBar.isTranslucent = true
  }
}
