//
//  TeamFilterTableViewCell.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 16/01/2024.
//

import UIKit

class TeamFilterTableViewCell: UITableViewCell {
  
  static let reuseIdentifier = "TeamFilterTableViewCell"
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    if selected {
      self.accessoryType = .checkmark
    } else {
      self.accessoryType = .none
    }
  }
}
