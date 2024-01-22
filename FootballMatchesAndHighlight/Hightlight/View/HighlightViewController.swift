//
//  HighlightView.swift
//  FootballMatchesAndHighlight
//
//  Created by Nguyen Thanh Thuc on 16/01/2024.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import Combine

class HighlightViewController: UIViewController {
  
  private var player: AVPlayer!
  private var playerController: AVPlayerViewController!
  private var activityIndicator: UIActivityIndicatorView!
  
  private var isPresented = false
  private var cancellables = Set<AnyCancellable>()
  
  private var highlightViewModel: HighlightViewModelProtocol
  
  init(highlightViewModel: HighlightViewModelProtocol) {
    self.highlightViewModel = highlightViewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .lightGray
    activityIndicator = UIActivityIndicatorView()
    activityIndicator.center = view.center
    view.addSubview(activityIndicator)
    setupListener()
    activityIndicator.startAnimating()
    setupNavigationTitle(title: "Video Highlight")
    highlightViewModel.viewDidLoad()
    
    view.accessibilityIdentifier = "highlightViewID"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
  
  private func setupNavigationTitle(title: String) {
    navigationItem.title = title
  }
  
  private func setupListener() {
    highlightViewModel
      .urlPublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] url in
        guard let self else { return }
        self.setupVideoView(withURL: url)
        setupPlayerObserver()
      }
      .store(in: &cancellables)
  }
  
  private func setupPlayerObserver() {
    player.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
  }
  
  private func setupVideoView(withURL url: URL) {
    
    player = AVPlayer(url:url)
    
    playerController = AVPlayerViewController()
    
    playerController.player = player
    
    playerController.allowsPictureInPicturePlayback = true
    
    playerController.delegate = self
    
    playerController.player?.play()
  }
  
  // MARK: - Observe video buffering
  override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard player != nil else {
      return
    }
    if keyPath == "timeControlStatus", let change = change, let newValue = change[NSKeyValueChangeKey.newKey] as? Int, let oldValue = change[NSKeyValueChangeKey.oldKey] as? Int {
      let oldStatus = AVPlayer.TimeControlStatus(rawValue: oldValue)
      let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue)
      if newStatus != oldStatus {
        DispatchQueue.main.async {[weak self] in
          guard let self else { return }
          if newStatus == .playing {
            if !isPresented {
              self.activityIndicator.isHidden = true
              self.present(self.playerController,animated:true,completion:nil)
              isPresented = true
            }
          } else {
            self.activityIndicator.isHidden = false
          }
        }
      }
    }
  }
  
  deinit {
    if player != nil {
      player.removeObserver(self, forKeyPath: "timeControlStatus")
      player = nil
      playerController = nil
    }
  }
}

// MARK: - AVPlayerViewControllerDelegate
extension HighlightViewController: AVPlayerViewControllerDelegate {
  func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
    let currentviewController =  navigationController?.visibleViewController
    
    if currentviewController != playerViewController {
      currentviewController?.present(playerViewController,animated: true,completion:nil)
    }
  }
  
  func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    self.playerController = nil
    self.player = nil
    navigationController?.popViewController(animated: true)
  }
}
