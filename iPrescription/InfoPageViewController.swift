//
//  InfoPageViewController.swift
//  iPrescription
//
//  Created by Marco on 07/08/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATA

import UIKit

class InfoPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    var pageNumber: Int = 2

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! PageViewController).pageIndex!
        if (index == 0) || (index == NSNotFound)
        {
            return nil
        }
        
        index--
        
        return self.viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
    {
        var index = (viewController as! PageViewController).pageIndex!
        
        if (index == NSNotFound) || (index == self.pageNumber)
        {
            return nil
        }
        
        index++
        
        return self.viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> (PageViewController?)
    {
        if (self.pageNumber == 0) || (index >= self.pageNumber)
        {
            return nil
        }
        
        let storyboard = UIStoryboard(name: "Main2", bundle: nil)
        
        switch index {
            
        case 0:
            let page = storyboard.instantiateViewControllerWithIdentifier("infoPage") as? PageViewController
            page?.pageIndex = 0
            return page
        case 1:
            let page = storyboard.instantiateViewControllerWithIdentifier("tutorialPage") as? PageViewController
            page?.pageIndex = 1
            return page
        default:
            return nil
        }
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return self.pageNumber
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int
    {
        return 0
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.dataSource = self
        self.view.backgroundColor = UIColor(red: 0.624, green: 0.988, blue: 0.898, alpha: 1)
        
        let first = self.viewControllerAtIndex(0)!
        let controllers = [first]
        self.setViewControllers(controllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 0.4)
        pageControl.currentPageIndicatorTintColor = UIColor(red: 0, green: 0.596, blue: 0.753, alpha: 1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneAction(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

}
