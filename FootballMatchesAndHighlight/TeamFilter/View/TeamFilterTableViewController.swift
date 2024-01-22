//
//  TeamFilterTableViewController.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 16/01/2024.
//

import UIKit
import Combine

class TeamFilterTableViewController: UITableViewController {
  
  private var teamFilterViewModel: TeamFilterViewModelProtocol
  private var cancellables = Set<AnyCancellable>()
  private var teams: [Team] = []
  private var activityIndicator: UIActivityIndicatorView!
  private var completion: ((_ selectedTeams: [Team]) -> Void)
  private lazy var dataSource = diffableDataSource()
  
  init(teamFilterViewModel: TeamFilterViewModelProtocol,
       completion: @escaping (([Team]) -> Void)) {
    self.teamFilterViewModel = teamFilterViewModel
    self.completion = completion
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    buildBarItemView()
    setupTableView()
    setupListenEvent()
    teamFilterViewModel.viewDidload()
    showLoadingView()
    setupTableViewDataSource()
  }
  
  private func buildBarItemView() {
    let barButton = UIBarButtonItem()
    barButton.title = "Done"
    barButton.target = self
    barButton.action = #selector(doneAction)
    navigationItem.rightBarButtonItem = barButton
    barButton.accessibilityIdentifier = "DoneButton"
  }
  
  private func setupTableView() {
    tableView.register(TeamFilterTableViewCell.self, forCellReuseIdentifier: TeamFilterTableViewCell.reuseIdentifier)
    tableView.allowsMultipleSelection = true
  }
  
  private func setupTableViewDataSource() {
    tableView.dataSource = diffableDataSource()
  }
  
  private func updateSnapshot() {
    var snapshot = dataSource.snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(teams, toSection: .main)
    dataSource.apply(snapshot)
  }
  
  private enum FilterSection {
    case main
  }
  
  // MARK: - Diffable data source
  
  private func diffableDataSource() -> UITableViewDiffableDataSource<FilterSection, Team> {
    let dataSource = UITableViewDiffableDataSource<FilterSection, Team>(tableView: tableView) { [weak self] tableView, indexPath, itemIdentifier in
      guard let self else { return UITableViewCell() }
      let cell = tableView.dequeueReusableCell(withIdentifier: TeamFilterTableViewCell.reuseIdentifier, for: indexPath)
      let team = self.teams[indexPath.row]
      cell.textLabel?.text = team.name
      return cell
    }
    return dataSource
  }
  
  @objc func doneAction(sender: UIBarButtonItem) {
    debugPrint("Done")
    teamFilterViewModel.selectionTeams = teams
    completion(teams.filter { $0.isSelected })
    dismiss(animated: true)
  }
  
  private func showLoadingView() {
    activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
    navigationItem.titleView = activityIndicator
    activityIndicator.startAnimating()
  }
  
  private func hideLoadingView() {
    activityIndicator.stopAnimating()
    activityIndicator.isHidden = true
  }
  
  private func setupListenEvent() {
    self.teamFilterViewModel
      .teamsPublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] error in
        switch error {
          case .finished:
            debugPrint("Finished")
          case .failure(let error):
            debugPrint(error)
            self?.showDefaultAlert(title: error.localizedDescription)
        }
      } receiveValue: {
        [weak self] teams in
        guard let self else {
          return
        }
        self.teams = teams
        self.updateSnapshot()
        self.hideLoadingView()
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Table view delegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    // Save selected to core data
    teams[indexPath.row].isSelected = true
  }
  
  override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
    teams[indexPath.row].isSelected = false
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let team = teams[indexPath.row]
    if team.isSelected {
      tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
    } else {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}
