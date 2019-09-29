//
//  PageViewController.swift
//  missions
//
//  Created by Umar Qattan on 9/22/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit

enum Pages: Int, CaseIterable {
    case home
    case input
    case gait
    case weight
    
    var index: Int {
        switch self {
        case .home:
            return 0
        case .input:
            return 1
        case .gait:
            return 2
        case .weight:
            return 3
        }
    }
    
    var nextPage: Pages? {
        switch self {
        case .home:
            return .input
        case .input:
            return .gait
        case .gait:
            return .weight
        case .weight:
            return nil
        }
    }
    
    var prevPage: Pages? {
        switch self {
        case .home:
            return nil
        case .input:
            return .home
        case .gait:
            return .input
        case .weight:
            return .gait
        }
    }
    
    var id: String {
        switch self {
        case .home:
            return "Page1"
        case .input:
            return "Page2"
        case .gait:
            return "Page3"
        case .weight:
            return "Page4"
        }
    }
    
    static func getPage(id: String) -> Pages? {
        switch id {
        case "Page1": return .home
        case "Page2": return .input
        case "Page3": return .gait
        case "Page4": return .weight
        default: return nil
        }
    }
}

class PageViewController: UIPageViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
        self.dataSource = self
        
        let homeVC = self.getViewController(page: .home)
        
        self.setViewControllers(
            [homeVC],
            direction: .forward,
            animated: true,
            completion: nil
        )

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if let view = view as? UIPageControl {
                view.currentPageIndicatorTintColor = .blue
                view.pageIndicatorTintColor = .lightGray
                view.backgroundColor = UIColor.clear
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PageViewController: UIPageViewControllerDelegate {
    
}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let id = viewController.restorationIdentifier,
            let page = Pages.getPage(id: id),
            let prevPage = page.prevPage
        else { return nil }
        
        if let parent = self.parent as? HomePageViewController, page == .weight {
            parent.toggleStartButton()
        }
        
        return self.getViewController(page: prevPage)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let id = viewController.restorationIdentifier,
            let page = Pages.getPage(id: id),
            let nextPage = page.nextPage
        else { return nil }
        
        if let parent = self.parent as? HomePageViewController, nextPage == .weight  {
            parent.toggleStartButton()
        }
        return self.getViewController(page: nextPage)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return Pages.allCases.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    
}

extension PageViewController {
    
    /// A helper method to get the UIViewController for the passed in page
    /// - Parameter page: a page corresponding to the UIViewController in the storyboard
    func getViewController(page: Pages) -> UIViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: page.id)
        return vc
    }
    
}
