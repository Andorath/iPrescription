//
//  InfoPageViewController.swift
//  iPrescription
//
//  Created by Marco on 07/08/14.
//  Copyright (c) 2014 Marco Salafia. All rights reserved.
//

//LOCALIZZATA

import UIKit

class InfoPageViewControllerOLD: UIPageViewController, UIPageViewControllerDataSource {
    
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
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch index {
            
        case 0:
            print("Ritorna presentation")
            return storyboard.instantiateViewControllerWithIdentifier("presentationController") as? PageViewController
        case 1:
            print("Ritorna firstTutorial")
            return storyboard.instantiateViewControllerWithIdentifier("firstTutorialController") as? PageViewController
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.dataSource = self
        self.view.backgroundColor = UIColor(red: 0.624, green: 0.988, blue: 0.898, alpha: 1)
        
        let first = self.viewControllerAtIndex(0)!
        let controllers = [first]
        self.setViewControllers(controllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
