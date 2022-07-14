//
//  NavigationViewController.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 04.06.2022.
//

import UIKit

class NavigationViewController: UIViewController {
    
    private var titleView: UIView!
    private var bodyView: UIView!
    private var hideTitle: Bool = false
    var bodyTopConstraint: NSLayoutConstraint?
            
    var orientation: UIDeviceOrientation {
        get {
            if (self.view.frame.width > self.view.frame.height) || UIDevice.current.orientation == .landscapeLeft {
                return UIDeviceOrientation.landscapeLeft
            } else if (self.view.frame.width < self.view.frame.height) || UIDevice.current.orientation.isPortrait {
                return UIDeviceOrientation.portrait
            } else if (self.view.frame.width > self.view.frame.height) || UIDevice.current.orientation == .landscapeRight {
                return UIDeviceOrientation.landscapeRight
            } else {
                return .unknown
            }
        }
    }
    
    var navigationView: UIView!
    
    private var extraPortraitConstraints: (() -> ())?
    private var extraLandscapeConstraints: (() -> ())?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeOrientation),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    func addExtraPortraitConstraints(_ extra: @escaping ()->()) {
        self.extraPortraitConstraints = extra
    }
    
    func addExtraLandscapeConstraints(_ extra: @escaping ()->()) {
        self.extraLandscapeConstraints = extra
    }
    
    func setupViews(for title: UIView, with body: UIView, _ hideTitle: Bool = false) {
        self.titleView = title
        self.bodyView = body
        self.hideTitle = hideTitle
    }
    
    @objc func changeOrientation(notification: Notification) {
        guard (notification.userInfo?["UIDeviceOrientationRotateAnimatedUserInfoKey"] as! Int == 1),
              (UIDevice.current.orientation != .unknown) else { return }
        self.setupNavigationBar()
    }
    
    func setupNavigationBar() {
        if self.navigationView != nil {
            self.navigationView.removeFromSuperview()
        }
        if self.orientation == .portrait {
            self.setupPortraitNavigation()
        } else if (self.orientation == .landscapeLeft) || (self.orientation == .landscapeRight) {
            self.setupLandscapeNavigation()
        } else {
            self.setupPortraitNavigation()
        }
    }
    
    func setupPortraitConstraints() {
        self.view.addSubview(self.navigationView)
        
        self.navigationView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        if self.hideTitle {
            self.bodyTopConstraint?.isActive = false
        }
        
        self.titleView?.removeFromSuperview()
        self.view.addSubview(titleView)
        
        self.titleView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor, constant: 20.0).isActive = true
        self.titleView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 20.0).isActive = true
        self.titleView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -20.0).isActive = true
        self.titleView.bottomAnchor.constraint(equalTo: self.bodyView.topAnchor, constant: -20.0).isActive = true
        
        if self.extraPortraitConstraints != nil {
            self.extraPortraitConstraints!()
        }
    }
    
    func setupLandscapeConstraints(profileButton: UIButton) {
        self.navigationView.translatesAutoresizingMaskIntoConstraints = false
        self.navigationView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.navigationView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.navigationView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
                
        profileButton.translatesAutoresizingMaskIntoConstraints = false
        profileButton.topAnchor.constraint(equalTo: self.navigationView.topAnchor, constant: 44).isActive = true
        profileButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 2.5).isActive = true
        profileButton.trailingAnchor.constraint(equalTo: self.navigationView.trailingAnchor, constant: -2.5).isActive = true
        
        self.titleView.removeFromSuperview()

        if self.hideTitle {
            self.bodyTopConstraint = self.bodyView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20.0)
            self.bodyTopConstraint!.isActive = true
        } else {
            self.view.addSubview(titleView)
            
            self.titleView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20.0).isActive = true
            self.titleView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 20.0).isActive = true
            self.titleView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: 20.0).isActive = true
            self.titleView.bottomAnchor.constraint(equalTo: self.bodyView.topAnchor, constant: -20.0).isActive = true
        }
        if self.extraLandscapeConstraints != nil {
            self.extraLandscapeConstraints!()
        }
    }
    
    func setupPortraitNavigation() {
        let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 44))
        let navigationItem = UINavigationItem()
        
        let profileImage = UIImage(systemName: "person")
        let profileButton = UIBarButtonItem(image: profileImage, style: .plain, target: nil, action: #selector(self.profileButtonTapped))
                
        navigationItem.rightBarButtonItem = profileButton
        
        navigationBar.setItems([navigationItem], animated: false)
        
        self.navigationView = navigationBar
        
        self.setupPortraitConstraints()
    }
    
    func setupLandscapeNavigation() {
        let navigationUIView = UIView(frame: CGRect(x: 0, y: 0, width: 88, height: self.view.frame.height))
        navigationUIView.backgroundColor = .systemGray6
        
        let profileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        profileButton.setImage(UIImage(systemName: "person"), for: .normal)
        profileButton.addTarget(self, action: #selector(self.profileButtonTapped), for: .touchUpInside)
        
        navigationUIView.addSubview(profileButton)
        
        self.navigationView = navigationUIView
        self.view.addSubview(self.navigationView)
        
        setupLandscapeConstraints(profileButton: profileButton)
    }
    
    @objc func profileButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(identifier: "ProfileViewController")
        self.showDetailViewController(profileVC, sender: self)
    }
}
