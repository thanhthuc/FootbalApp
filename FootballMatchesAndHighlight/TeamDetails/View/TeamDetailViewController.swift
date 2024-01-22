//
//  TeamDetailView.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 16/01/2024.
//

import Foundation
import UIKit
import Combine

class TeamDetailViewController: UIViewController {
  
  private var teamNameLabel: UILabel!
  private var teamLogoImageView: UIImageView!
  private var matchesListCollectionView: UICollectionView!
  private let teamDetailViewModel: TeamDetailViewModelProtocol
  private lazy var dataSource = configDiffableDataSource()
  private var cancellables = Set<AnyCancellable>()
  private var allMatches: [Matches] = []
  private var teamsToFetch: [Team] = []
  
  init(teamDetailViewModel: TeamDetailViewModelProtocol) {
    self.teamDetailViewModel = teamDetailViewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .lightGray
    setupNavigationTitle()
    initViews()
    setupDefaultData()
    setupLayoutViews()
    borderViews()
    setupListener()
    setupCollectionViewAndDataSource()
    teamDetailViewModel.viewDidload()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  // Make auto height dimension layout
  private func createBasicLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(300)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(300)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitem: item,
      count: 1
    )
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 16
    section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10)
    
    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
  }
  
  private func initViews() {
    teamNameLabel = UILabel()
    teamNameLabel.isAccessibilityElement = true
    teamNameLabel.accessibilityLabel = "teamNameLabelID"
    teamNameLabel.textAlignment = .center
    teamLogoImageView = UIImageView()
    teamLogoImageView.backgroundColor = .white
    let autoSizeLayout = createBasicLayout()
    matchesListCollectionView = UICollectionView(
      frame: self.view.frame,
      collectionViewLayout: autoSizeLayout
    )
    view.addSubview(teamNameLabel)
    view.addSubview(teamLogoImageView)
    view.addSubview(matchesListCollectionView)
  }
  
  private func setupDefaultData() {
    teamNameLabel.text = "team name"
    teamLogoImageView.image = UIImage(systemName: "person.2")
  }
  
  private func setupLayoutViews() {
    teamNameLabel.translatesAutoresizingMaskIntoConstraints = false
    teamNameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
    teamNameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    teamNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
    
    teamLogoImageView.translatesAutoresizingMaskIntoConstraints = false
    teamLogoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    teamLogoImageView.heightAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
    teamLogoImageView.widthAnchor.constraint(equalTo: teamLogoImageView.heightAnchor).isActive = true
    teamLogoImageView.topAnchor.constraint(equalTo: teamNameLabel.bottomAnchor, constant: 3).isActive = true
    
    matchesListCollectionView.translatesAutoresizingMaskIntoConstraints = false
    matchesListCollectionView.topAnchor.constraint(equalTo: teamLogoImageView.bottomAnchor, constant: 5).isActive = true
    matchesListCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    matchesListCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    matchesListCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
  }
  
  private func borderViews() {
    teamLogoImageView.layer.cornerRadius = 20
  }
  
  private func setupCollectionViewAndDataSource() {
    matchesListCollectionView.register(MatchesListCollectionViewCell.self,
                                       forCellWithReuseIdentifier: MatchesListCollectionViewCell.reuseIndentifier)
    matchesListCollectionView.dataSource = dataSource
    updateSnapshot()
  }
  
  enum DetailSection {
    case all
  }
  
  private func updateSnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<DetailSection, Matches>()
    snapshot.appendSections([.all])
    snapshot.appendItems(allMatches, toSection: .all)
    dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  private func setupNavigationTitle() {
    navigationItem.title = "Team Detail"
  }
  
  private func setupListener() {
    teamDetailViewModel
      .teamPublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] items in
        guard let self else { return }
        self.fillData(withTeam: items.team)
        self.allMatches = items.allMatches
        self.teamsToFetch = items.teamsToFetch
        self.updateSnapshot()
      }.store(in: &cancellables)
    
  }
  
  private func fillData(withTeam team: Team) {
    self.teamNameLabel.text = team.name
    DispatchQueue.global(qos: .background).async {
      
      // Convert data to image in background
      guard let url = URL(string: team.logo) else {
        return
      }
      guard let data = NSData(contentsOf: url) as? Data else {
        return
      }
      let imageFromData = UIImage(data: data)
      
      DispatchQueue.main.async {
        // Populate image to UI in main thread
        self.teamLogoImageView.image = imageFromData
      }
    }
  }
  
  private func configDiffableDataSource() -> UICollectionViewDiffableDataSource<DetailSection, Matches> {
    let dataSource = UICollectionViewDiffableDataSource<DetailSection, Matches>(collectionView: matchesListCollectionView) { [weak self] collectionView, indexPath, matchesIdentifier in
      
      guard let self else { return MatchesListCollectionViewCell() }
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: MatchesListCollectionViewCell.reuseIndentifier,
        for: indexPath) as? MatchesListCollectionViewCell else {
        return MatchesListCollectionViewCell()
      }
      cell.changeModeView(isHighLightMode: false)
      cell.teamsToFetch = self.teamsToFetch
      cell.matches = self.allMatches[indexPath.item]
      return cell
    }
    
    return dataSource
  }
}
