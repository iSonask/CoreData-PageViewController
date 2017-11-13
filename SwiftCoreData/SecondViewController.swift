//
//  SecondViewController.swift
//  SwiftCoreData
//
//  Created by Akash on 10/11/17.
//  Copyright © 2017 Akash. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, StoryboardRedirectionProtocol {

    @IBOutlet var twoButton: UIButton!
    @IBOutlet var oneButton: UIButton!
    @IBOutlet var threeButton: UIButton!
    let pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
    
    @IBOutlet var containerView: UIView!
    private let viewControllers: [UIViewController] = [
        OneViewController.getViewController(),
        TwoViewController.getViewController(),
        ThreeViewController.getViewController()
    ]
    private enum TabOption: Int {
        case one
        case two
        case three
    }
    private var selectedTab: TabOption = .one {
        didSet{
            switch selectedTab {
                
            case .one:
                oneButton.isSelected = true
                twoButton.isSelected = false
                threeButton.isSelected = false
            case .two:
                oneButton.isSelected = false
                twoButton.isSelected = true
                threeButton.isSelected = false
            case .three:
                oneButton.isSelected = false
                twoButton.isSelected = false
                threeButton.isSelected = true
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.5, alpha: 1)
        // Do any additional setup after loading the view.
        containerView.backgroundColor = .clear
        setupPageViewControllers()
    }
    func setupPageViewControllers()  {
        pageController.setViewControllers([viewControllers[0]], direction: .forward, animated: true, completion: nil)
        pageController.dataSource = self
        pageController.delegate = self
        addChildViewController(pageController)
        pageController.view.backgroundColor = .clear
        pageController.didMove(toParentViewController: self)
        pageController.view.layoutAttachAll(to: containerView)

    }
    
    @IBAction func oneButtonAction(_ sender: Any) {
        selectedTab = .one
        showPageContent(tab: 0)
    }
    
    @IBAction func threeButtonAction(_ sender: Any) {
        selectedTab = .three
        showPageContent(tab: 2)
    }
    @IBAction func twoButtonAction(_ sender: Any) {
        selectedTab = .two
        showPageContent(tab: 1)
    }
}
// MARK: - Methods
extension SecondViewController {
    
    /// Show page content
    ///
    /// - Parameter index: Tab Index
    private func showPageContent(tab index: Int) {
        
        var prevIndex: Int = 0
        if let viewController = pageController.viewControllers?.first {
            prevIndex = viewControllers.index(of: viewController) ?? 0
        }
        
        if index < viewControllers.count {
            let direction: UIPageViewControllerNavigationDirection = (index > prevIndex) ? .forward : .reverse
            pageController.setViewControllers([viewControllers[index]], direction: direction, animated: true, completion: nil)
        }
        
    }
    
}

extension SecondViewController: UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let viewController = pageViewController.viewControllers?.first {
            selectedTab = TabOption(rawValue: viewControllers.index(of: viewController) ?? 0 ) ?? .one
        }
        
    }
}
extension SecondViewController: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = viewControllers.index(of: viewController) ?? 0
        
        if index > 0 {
            return viewControllers[index - 1]
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let index = viewControllers.index(of: viewController) ?? 0
        
        if index < viewControllers.count - 1  {
            return viewControllers[index + 1]
        }
        
        return nil
    }
}




protocol RedirectionProtocol {
    
    static func getViewController() -> UIViewController
    
}

protocol XIBRedirectionProtocol: RedirectionProtocol {
    
    static var nibIdentifier: String { get }
    
}

extension XIBRedirectionProtocol where Self: UIViewController {
    
    static var nibIdentifier: String {
        return String(describing: self)
    }
    
    private static func fromNib() -> Self {
        let viewController = Self(nibName: nibIdentifier, bundle:nil)
        return viewController
    }
    
    static func getViewController() -> UIViewController {
        return fromNib()
    }
    
}



protocol StoryboardRedirectionProtocol: RedirectionProtocol {
    
    static var storyboard: UIStoryboard { get }
    
    static var storyboardIdentifier: String { get }
    
}


extension StoryboardRedirectionProtocol where Self: UIViewController {
    
    
    static var storyboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    
    
    private static func fromStoryboard() -> Self {
        
        let viewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as! Self
        return viewController
    }
    
    static func getViewController() -> UIViewController {
        return fromStoryboard()
    }
    
}


extension UIView {
    
    @discardableResult
    func fromNib<T : UIView>() -> T? {
        guard let view = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?[0] as? T else {
            // xib not loaded, or it's top view is of the wrong type
            return nil
        }
        view.backgroundColor = .clear
        view.layoutAttachAll(to: self)
        return view
    }
    
    func layoutAttachAll(to view: UIView){
        
        view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String : Any] = [
            "view" : self
        ]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: [:], views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: [:], views: views))
        
        setNeedsLayout()
        layoutIfNeeded()
        view.layoutIfNeeded()
        
    }
    
}

