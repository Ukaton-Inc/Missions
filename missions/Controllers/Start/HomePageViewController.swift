//
//  HomePageViewController.swift
//  missions
//
//  Created by Umar Qattan on 9/22/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit

class HomePageViewController: UIViewController {
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.setupContainerView()
    }
    
    @IBAction func onStartButtonTapped(sender: UIButton) {
    
        let nc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectDeviceNavigationController")
        
        nc.modalPresentationStyle = .overFullScreen
        
        self.present(nc, animated: true, completion: nil)
    }

}

extension HomePageViewController {
    func setupContainerView() {
        guard let childVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PageViewController") as? PageViewController else { return }
        
        self.addChild(childVC)
        childVC.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        childVC.view.frame = containerView.bounds
        
        self.containerView.addSubview(childVC.view)
        childVC.didMove(toParent: self)
    }

    
    func toggleStartButton() {
        self.startButton.isEnabled = true
    }
}
