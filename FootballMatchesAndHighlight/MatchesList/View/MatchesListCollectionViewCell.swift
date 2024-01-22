//
//  MatchesListCollectionViewCell.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 16/01/2024.
//

import UIKit
import Combine

class MatchesListCollectionViewCell: UICollectionViewCell {
  static let reuseIndentifier = "MatchesListCollectionViewCell"
  
  var titleView: UIView!
  var homeView: UIView!
  var awayView: UIView!
  var highlightButton: UIButton!
  
  // container view
  var containerView: UIView!
  
  // subview inside title view
  var dateLabel: UILabel!
  var descriptionLabel: UILabel!
  var winnerLabel: UILabel!
  
  // subview inside winner view
  var homeLogoView: UIImageView!
  var homeNameLabel: UILabel!
  
  // subview inside away view
  var awayLogoView: UIImageView!
  var awayNameLabel: UILabel!
  
  // vs label
  var vsLabel: UILabel!
  
  // stored data
  var matches: Matches? {
    didSet {
      fillMatchesData()
    }
  }
  
  var teamsToFetch: [Team] = []
  var homeTeam: Team?
  var awayTeam: Team?
  
  // Action react
  var teamSelectedCompletion: ((Team) -> Void)?
  var highlightCompletion: ((URL) -> Void)?
  
  private var isHighLightMode = false
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    convenienceInit()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    convenienceInit()
  }
  
  override func layoutSubviews() {
    borderRadiusViews()
  }
  
  func convenienceInit() {
    initSubView()
    setupContentPriority()
    setupContainerView()
    setupTitleView()
    setupHomeView()
    setupAwayView()
    setupHighlightButton()
    setupVsLabel()
    setupTapAtion()
    
    
    populateDefaultData()
  }
  
  private func initSubView() {
    containerView = UIView()
    titleView = UIView()
    descriptionLabel = UILabel()
    dateLabel = UILabel()
    winnerLabel = UILabel()
    
    homeView = UIView()
    homeLogoView = UIImageView()
    homeNameLabel = UILabel()
    awayView = UIView()
    awayLogoView = UIImageView()
    awayNameLabel = UILabel()
    
    highlightButton = UIButton()
    vsLabel = UILabel()
    
    homeView.backgroundColor = .white
    awayView.backgroundColor = .white
  }
  
  private func setupContentPriority() {
    dateLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    descriptionLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    winnerLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    homeNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    awayNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
  }
  
  private func setupContainerView() {
    contentView.addSubview(containerView)
    containerView.translatesAutoresizingMaskIntoConstraints = false
    containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
    containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
    //      containerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
    containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
  }
  
  private func setupTitleView() {
    
    titleView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(titleView)
    titleView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    titleView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
    titleView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    
    // Subview setup
    titleView.addSubview(dateLabel)
    dateLabel.translatesAutoresizingMaskIntoConstraints = false
    dateLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 3).isActive = true
    dateLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 3).isActive = true
    dateLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 3).isActive = true
    dateLabel.textAlignment = .center
    
    titleView.addSubview(descriptionLabel)
    descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    descriptionLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 3).isActive = true
    descriptionLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
    descriptionLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
    descriptionLabel.textAlignment = .center
    
    titleView.addSubview(winnerLabel)
    winnerLabel.translatesAutoresizingMaskIntoConstraints = false
    winnerLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 3).isActive = true
    winnerLabel.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 3).isActive = true
    winnerLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: 3).isActive = true
    winnerLabel.bottomAnchor.constraint(equalTo: titleView.bottomAnchor, constant: -3).isActive = true
    winnerLabel.textAlignment = .center
    
    titleView.backgroundColor = .white
  }
  
  private func setupHomeView() {
    containerView.addSubview(homeView)
    homeView.translatesAutoresizingMaskIntoConstraints = false
    homeView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 3).isActive = true
    homeView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 3).isActive = true
    
    // subview setup
    homeView.addSubview(homeLogoView)
    homeLogoView.translatesAutoresizingMaskIntoConstraints = false
    homeLogoView.leadingAnchor.constraint(equalTo: homeView.leadingAnchor, constant: 20).isActive = true
    homeLogoView.topAnchor.constraint(equalTo: homeView.topAnchor, constant: 3).isActive = true
    homeLogoView.trailingAnchor.constraint(equalTo: homeView.trailingAnchor, constant: -20).isActive = true
    homeLogoView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    homeLogoView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    homeLogoView.contentMode = .scaleToFill
    
    homeView.addSubview(homeNameLabel)
    homeNameLabel.translatesAutoresizingMaskIntoConstraints = false
    homeNameLabel.leadingAnchor.constraint(equalTo: homeView.leadingAnchor).isActive = true
    homeNameLabel.topAnchor.constraint(equalTo: homeLogoView.bottomAnchor, constant: 3).isActive = true
    homeNameLabel.trailingAnchor.constraint(equalTo: homeView.trailingAnchor).isActive = true
    homeNameLabel.bottomAnchor.constraint(equalTo: homeView.bottomAnchor, constant: -3).isActive = true
    homeNameLabel.numberOfLines = 0
    homeNameLabel.lineBreakMode = .byWordWrapping
    homeNameLabel.textAlignment = .center
  }
  
  private func setupAwayView() {
    containerView.addSubview(awayView)
    awayView.translatesAutoresizingMaskIntoConstraints = false
    awayView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 3).isActive = true
    awayView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 3).isActive = true
    awayView.widthAnchor.constraint(equalTo: homeView.widthAnchor, multiplier: 1).isActive = true
    awayView.heightAnchor.constraint(equalTo: homeView.heightAnchor, multiplier: 1).isActive = true
    
    // subview setup
    awayView.addSubview(awayLogoView)
    awayLogoView.translatesAutoresizingMaskIntoConstraints = false
    awayLogoView.trailingAnchor.constraint(equalTo: awayView.trailingAnchor, constant: -20).isActive = true
    awayLogoView.leadingAnchor.constraint(equalTo: awayView.leadingAnchor, constant: 20).isActive = true
    awayLogoView.topAnchor.constraint(equalTo: awayView.topAnchor).isActive = true
    awayLogoView.heightAnchor.constraint(equalTo: homeLogoView.heightAnchor, multiplier: 1).isActive = true
    awayLogoView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    awayLogoView.contentMode = .scaleToFill
    
    awayView.addSubview(awayNameLabel)
    awayNameLabel.translatesAutoresizingMaskIntoConstraints = false
    awayNameLabel.leadingAnchor.constraint(equalTo: awayView.leadingAnchor).isActive = true
    awayNameLabel.trailingAnchor.constraint(equalTo: awayView.trailingAnchor).isActive = true
    awayNameLabel.topAnchor.constraint(equalTo: awayLogoView.bottomAnchor, constant: 3).isActive = true
    awayNameLabel.bottomAnchor.constraint(equalTo: awayView.bottomAnchor, constant: -3).isActive = true
    awayNameLabel.numberOfLines = 0
    awayNameLabel.lineBreakMode = .byWordWrapping
    awayNameLabel.textAlignment = .center
  }
  
  private func setupHighlightButton() {
    containerView.addSubview(highlightButton)
    highlightButton.setTitle("Highlight", for: .normal)
    highlightButton.backgroundColor = .cyan
    highlightButton.translatesAutoresizingMaskIntoConstraints = false
    highlightButton.topAnchor.constraint(equalTo: awayView.bottomAnchor, constant: 5).isActive = true
    highlightButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 0).isActive = true
    highlightButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 0).isActive = true
    highlightButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -3).isActive = true
  }
  
  private func setupVsLabel() {
    containerView.addSubview(vsLabel)
    vsLabel.font = UIFont.systemFont(ofSize: 33, weight: .bold)
    vsLabel.textColor = .darkGray
    vsLabel.translatesAutoresizingMaskIntoConstraints = false
    vsLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
    vsLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
  }
  
  private func populateDefaultData() {
    dateLabel.text = "date label"
    winnerLabel.text = "home label"
    vsLabel.text = "VS"
    homeNameLabel.text = "winner name label"
    descriptionLabel.text = "description label"
    awayNameLabel.text = "away name label"
    homeLogoView.image = UIImage(systemName: "person.2")
    awayLogoView.image = UIImage(systemName: "person.2")
  }
  
  private func borderRadiusViews() {
    backgroundColor = .white
    layer.cornerRadius = 15
    layer.shadowOffset = CGSize(width: 1, height: -1)
    layer.shadowRadius = 5
    layer.shadowOpacity = 0.5
    layer.shadowColor = UIColor.black.cgColor
    let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: UIRectCorner.allCorners, cornerRadii: CGSize(width: 10, height: 10))
    layer.shadowPath = path.cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    
    // highlight button
    highlightButton.layer.cornerRadius = 15
  }
  
  @objc private func homeTeamTapAction() {
    // Move to team detail
    if let homeTeam,
       let teamSelectedCompletion {
      debugPrint("winner team")
      teamSelectedCompletion(homeTeam)
    }
  }
  
  @objc private func awayTeamTapAction() {
    // Move to team detail
    if let awayTeam,
       let teamSelectedCompletion {
      debugPrint("away team")
      teamSelectedCompletion(awayTeam)
    }
  }
  
  @objc private func highlightAction() {
    // Move to highlight team
    debugPrint("highLight")
    if let urlString = matches?.highlights,
       let url = URL(string: urlString),
       let highlightCompletion {
      highlightCompletion(url)
    }
  }
  
  private func setupTapAtion() {
    homeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(homeTeamTapAction)))
    awayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(awayTeamTapAction)))
    highlightButton.addTarget(self, action: #selector(highlightAction), for: .touchUpInside)
  }
  
  func fillMatchesData() {
    if let matches {
      dateLabel.text = matches.date
      descriptionLabel.text = matches.description
      winnerLabel.text = "Winner: \(matches.winner ?? "")"
      homeNameLabel.text = "Home: \n \(matches.home ?? "")"
      
      awayNameLabel.text = "Away: \n \(matches.away ?? "")"
      let homeTeam = teamsToFetch.first(where: { $0.name == matches.home })
      
      // Store and cache image
      self.homeLogoView.cacheAndSaveImage(homeTeam?.logo)
      
      let awayTeam = teamsToFetch.first(where: { $0.name == matches.away })
      // Store and cache image
      self.awayLogoView.cacheAndSaveImage(awayTeam?.logo)
      
      self.homeTeam = homeTeam
      self.awayTeam = awayTeam
    }
  }
  
  func changeModeView(isHighLightMode: Bool) {
    self.isHighLightMode = isHighLightMode
    if !isHighLightMode {
      winnerLabel.isHidden = true
      highlightButton.isEnabled = false
      highlightCompletion = nil
      highlightButton.backgroundColor = .lightGray
    } else {
      winnerLabel.isHidden = false
      highlightButton.isEnabled = true
      highlightButton.backgroundColor = .systemBlue
    }
  }
}
