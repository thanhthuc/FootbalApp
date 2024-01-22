//
//  AlertHelper.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 21/01/2024.
//

import Foundation
import UIKit

extension UIViewController {
  
  func showDefaultErrorAlert(title: String) {
    let alert = UIAlertController(title: "Alert", message: title, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .cancel)
    alert.addAction(alertAction)
    self.present(alert, animated: true)
  }
}
