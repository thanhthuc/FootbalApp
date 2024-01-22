//
//  MatchesListViewController.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 16/01/2024.
//

import Foundation
import UIKit
import Combine

class MatchesListViewController: UIViewController {
  
  private var matchesListCollectionView: UICollectionView!
  private var matchesSegmentControl: UISegmentedControl!
  private var activityIndicatorView: UIActivityIndicatorView!
  private var matchesListViewModel: MatchesListViewModelProtocol
  private var cancellables = Set<AnyCancellable>()
  private var teams: [Team] = []
  private var upcoming: [Matches] = []
  private var previous: [Matches] = []
  private var filterUpcoming: [Matches] = []
  private var filterPrevious: [Matches] = []
  
  private lazy var dataSource = configDiffableDataSource()
  
  init(matchesListViewModel: MatchesListViewModelProtocol) {
    self.matchesListViewModel = matchesListViewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = .white
    
    setupLayoutView()
    
    setupCollectionViewDataSourceAndDelegate()
    
    setupListener()
    
    registerCellForCollectionView()
    
    setupNavigationTitle(title: "Matches List")
    
    setupActionMatchesSegmentControl()
    
    setupFilterView()
    
    matchesListViewModel.viewDidLoad()
    
    setupAppearance()
    
    showAnimating()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  // MARK: - Private function
  
  private func setupListener() {
    matchesListViewModel
      .teamsListPublisher
      .sink {[weak self] completionError in
        switch completionError {
          case .finished:
            debugPrint("finish")
          case .failure(let error):
            debugPrint("error \(error)")
            self?.showDefaultErrorAlert(title: error.localizedDescription)
        }
      } receiveValue: { [weak self] teams in
        guard let self else { return }
        self.teams = teams
      }.store(in: &cancellables)

    
    matchesListViewModel
      .matchesListPublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] completionError in
        switch completionError {
          case .finished:
            debugPrint("finished")
          case .failure(let error):
            // Show popup error
            debugPrint(error.localizedDescription)
            self?.showDefaultErrorAlert(title: error.localizedDescription)
        }
      } receiveValue: {
        [weak self] (upcoming: [Matches], previous: [Matches]) in
        guard let self else { return }
        self.upcoming = upcoming
        self.previous = previous
        self.filterUpcoming = upcoming
        self.filterPrevious = previous
        self.updateSnapshot()
        self.hideAnimating()
      }
      .store(in: &cancellables)
  }
  
  private func showAnimating() {
    activityIndicatorView.startAnimating()
  }
  
  private func hideAnimating() {
    self.activityIndicatorView.stopAnimating()
    self.activityIndicatorView.isHidden = true
  }
  
  private func setupAppearance() {
    matchesSegmentControl.selectedSegmentIndex = 0
    matchesSegmentControl.accessibilityIdentifier = "matchesSegmentControlID"
  }
  
  private func setupActionMatchesSegmentControl() {
    matchesSegmentControl.addTarget(self, action: #selector(changeFilterMatches), for: .valueChanged)
    matchesSegmentControl.addTarget(self, action: #selector(changeFilterMatches), for: .touchUpInside)
  }
  
  @objc func changeFilterMatches(_ sender: UISegmentedControl) {
    debugPrint(sender.selectedSegmentIndex)
    // call view model
    matchesListViewModel.isUpcoming = sender.selectedSegmentIndex == 0 ? false : true
    updateSnapshot()
  }
  
  private func setupFilterView() {
    // create table view and display after press to button filter
    let filterButton = UIBarButtonItem()
    filterButton.target = self
    filterButton.title = "Team Filter"
    filterButton.action = #selector(showFilter)
    navigationItem.rightBarButtonItem = filterButton
    
    // UI test ID
    filterButton.accessibilityIdentifier = "filterButton"
  }
  
  @objc private func showFilter(sender: UIButton) {
    let navigation = UINavigationController()
    let teamFilterViewModel = TeamFilterViewModel(
      teamLocalRepository: matchesListViewModel.getTeamLocalRespository(),
      teamRemoteRepository: matchesListViewModel.getTeamRemoteRespository()
    )
    let filterViewController = TeamFilterTableViewController(teamFilterViewModel: teamFilterViewModel) {[weak self] selectedTeams in
      
      guard let self else { return }
      
      if !selectedTeams.isEmpty {
        
        self.filterUpcoming = upcoming.filter { matches in
          return selectedTeams.contains { team in
            return matches.away == team.name || matches.home == team.name
          }
        }
        
        self.filterPrevious = previous.filter({ matches in
          return selectedTeams.contains { team in
            return matches.away == team.name || matches.home == team.name
          }
        })
        
      } else {
        self.filterUpcoming = self.upcoming
        self.filterPrevious = self.previous
      }
      updateSnapshot()
    }
    
    navigation.viewControllers = [filterViewController]
    present(navigation, animated: true)
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
  
  private func setupLayoutView() {
    activityIndicatorView = UIActivityIndicatorView(
      frame: CGRect(x: 0, y: 0, width: 30, height: 30)
    )
    activityIndicatorView.accessibilityIdentifier = "activityIndicatorViewID"
    view.addSubview(activityIndicatorView)
    activityIndicatorView.center = view.center
    let autoSizeLayout = createBasicLayout()
    matchesListCollectionView = UICollectionView(
      frame: self.view.frame,
      collectionViewLayout: autoSizeLayout
    )
    view.addSubview(matchesListCollectionView)
    matchesListCollectionView.translatesAutoresizingMaskIntoConstraints = false
    
    // segment control
    matchesSegmentControl = UISegmentedControl()
    matchesSegmentControl.selectedSegmentTintColor = .lightGray
    matchesSegmentControl.insertSegment(withTitle: "Previous Matches", at: 0, animated: false)
    matchesSegmentControl.insertSegment(withTitle: "Upcoming Matches", at: 1, animated: false)
    matchesSegmentControl.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(matchesSegmentControl)
    matchesSegmentControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    matchesSegmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
    matchesSegmentControl.bottomAnchor.constraint(equalTo: matchesListCollectionView.topAnchor, constant: -5).isActive = true
    
    // collection view
    matchesListCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    matchesListCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    matchesListCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    view.bringSubviewToFront(activityIndicatorView)
  }
  
  private func setupCollectionViewDataSourceAndDelegate() {
    matchesListCollectionView.dataSource = dataSource
    updateSnapshot()
  }
  
  private func updateSnapshot() {
    var snapshot = NSDiffableDataSourceSnapshot<MatchesListSection, Matches>()
    snapshot.appendSections([.main])
    snapshot.appendItems(matchesListViewModel.isUpcoming ? filterUpcoming : filterPrevious, toSection: .main)
    dataSource.apply(snapshot, animatingDifferences: false)
  }
  
  private func registerCellForCollectionView() {
    matchesListCollectionView.register(MatchesListCollectionViewCell.self, forCellWithReuseIdentifier: MatchesListCollectionViewCell.reuseIndentifier)
  }
  
  private func setupNavigationTitle(title: String) {
    navigationItem.title = title
  }
  
  private var matchListDataSource: UICollectionViewDiffableDataSource<MatchesListSection, Matches>!
  
  private enum MatchesListSection: Int {
    case main
  }
  
  // MARK: - Diffable data source
  private func configDiffableDataSource() -> UICollectionViewDiffableDataSource<MatchesListSection, Matches> {
    let dataSource = UICollectionViewDiffableDataSource<MatchesListSection, Matches>(collectionView: matchesListCollectionView) { [weak self] collectionView, indexPath, matchesIdentifier in
      
      guard let self else { return MatchesListCollectionViewCell() }
      
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: MatchesListCollectionViewCell.reuseIndentifier,
        for: indexPath) as? MatchesListCollectionViewCell else {
        return MatchesListCollectionViewCell()
      }
      cell.highlightButton.accessibilityIdentifier = "highlightButtonID\(indexPath.row)"
      cell.teamsToFetch = self.teams
      if matchesListViewModel.isUpcoming {
        cell.changeModeView(isHighLightMode: false)
        cell.matches = self.filterUpcoming[indexPath.item]
      } else {
        cell.changeModeView(isHighLightMode: true)
        cell.matches = self.filterPrevious[indexPath.item]
      }
      
      cell.teamSelectedCompletion = { [weak self] team in
        // Navigate to team detail
        guard let self else { return }
        var allMatches = self.upcoming
        allMatches.append(contentsOf: self.previous)
        allMatches = allMatches.filter { $0.winner == team.name || $0.away == team.name }
        let teamDetailViewModel = TeamDetailViewModel(team: team,
                                                      allMatches: allMatches,
                                                      teamsToFetch: self.teams)
        let detailTeamViewController = TeamDetailViewController(teamDetailViewModel: teamDetailViewModel)
        navigationController?.pushViewController(detailTeamViewController, animated: true)
      }
      cell.highlightCompletion = { [weak self] url in
        // navigate to highlight video view
        guard let self else { return }
        let highlightViewModel = HighlightViewModel(url: url)
        let highlightViewController = HighlightViewController(highlightViewModel: highlightViewModel)
        self.navigationController?.pushViewController(highlightViewController, animated: true)
      }
      return cell
    }
    return dataSource
  }
}
