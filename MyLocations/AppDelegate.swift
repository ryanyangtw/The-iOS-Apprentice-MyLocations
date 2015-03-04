//
//  AppDelegate.swift
//  MyLocations
//
//  Created by Ryan on 2015/2/15.
//  Copyright (c) 2015年 Ryan. All rights reserved.
//

import UIKit
import CoreData

let MyManagedObjectContextSaveDidFailNotification = "MyManagedObjectContextSaveDidFailNotification"

func fatalCoreDataError(error: NSError?) {
  if let error = error {
    println("*** Fatal error: \(error), \(error.userInfo)")
  }
  
  NSNotificationCenter.defaultCenter().postNotificationName(MyManagedObjectContextSaveDidFailNotification, object: error)
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch.
    
    customizeAppearance()
    
    let tabBarController = window!.rootViewController as UITabBarController
    
    if let tabBarViewControllers = tabBarController.viewControllers {
      // tab 1
      let currentLocationViewController = tabBarViewControllers[0] as CurrentLocationViewController
      
      currentLocationViewController.managedObjectContext = managedObjectContext
      
      // tab 2
      let navigationController = tabBarViewControllers[1] as UINavigationController
      let locationsViewController = navigationController.viewControllers[0] as LocationsViewController
      locationsViewController.managedObjectContext = managedObjectContext
      
      // Fix the bug in ios8 (page.194). To sync the cache (trigger viewDidLoad in LocationsViewController)
      let forceTheViewLoad = locationsViewController.view
      
      // tab 3
      let mapViewController = tabBarViewControllers[2] as MapViewController
      mapViewController.managedObjectContext = managedObjectContext
    }
    
    // Registered the notification with NSNotificationCenter
    listenForFatalCoreDataNotifications()
    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
  // Registered notification with NSNotificationCenter
  func listenForFatalCoreDataNotifications() {
    // 1 Tell NSNotificationCenter that you wnat to be notified whenver a MyManagedObjectContextSaveDidFailNotification is posted
    NSNotificationCenter.defaultCenter().addObserverForName( MyManagedObjectContextSaveDidFailNotification, object: nil, queue: NSOperationQueue.mainQueue(),
      usingBlock: { notification in
        
        // 2 Create a UIAlertController to show the error message
        let alert = UIAlertController(title: "Internal Error", message: "There was a fatal error in the app and it cannot continue.\n\n" + "Press OK to terminate the app. Sorry for the inconvenience.", preferredStyle: .Alert)
        
        // 3
        let action = UIAlertAction(title: "OK", style: .Default) { _ in
          let exception = NSException(name: NSInternalInconsistencyException, reason: "Fatal Core Data error", userInfo: nil)

          exception.raise()
        }
        
        alert.addAction(action)

        // 4
        self.viewControllerForShowingAlert().presentViewController(alert, animated: true, completion: nil)
    })
    
  }
  
  
  // 5
  func viewControllerForShowingAlert() -> UIViewController {
    let rootViewController = self.window!.rootViewController!
    
    // TODO: presentedViewController????
    if let presentedViewController = rootViewController.presentedViewController {
      return presentedViewController
    } else {
      return rootViewController
    }
    
  }
  
  func customizeAppearance() {
    // TODO: what does this UINavigationBar mean?
    UINavigationBar.appearance().barTintColor = UIColor.blackColor()
    
    UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    
    // TODO: what does this UITabBar mean?
    UITabBar.appearance().barTintColor = UIColor.blackColor()
    
    let tintColor = UIColor(red: 255/255.0, green: 238/255.0, blue: 136/255.0, alpha: 1.0)
    
    UITabBar.appearance().tintColor = tintColor
  }
  
  
// MARK: - Core Data
  
 
  // This code creates a lazily loded instance variable named managedObjectContext
  lazy var managedObjectContext: NSManagedObjectContext = {
    
    // 1 Create an NSURL object pointing at this folder
    if let modelURL = NSBundle.mainBundle().URLForResource("DataModel", withExtension: "momd") {
      
      // 2 Create NSManagedObjectModel fromt the URL
      if let model = NSManagedObjectModel(contentsOfURL: modelURL) {
        
        // 3 NSPersistentStoreCoordinator is in charge of the SQLite database
        let coordinator = NSPersistentStoreCoordinator( managedObjectModel: model)
        
        // 4 Create an NSURL object pointing at the DataStore.sqlite file
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        let documentsDirectory = urls[0] as NSURL
        let storeURL = documentsDirectory.URLByAppendingPathComponent("DataStore.sqlite")
        
        println("\(storeURL)")
        
        // 5 Add the SQLite database to the store coordinator
        var error: NSError?
        
        if let store = coordinator.addPersistentStoreWithType( NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil, error: &error) {
          
          // 6 Create the NSManagedObjectContext object and return it
          let context = NSManagedObjectContext()
          context.persistentStoreCoordinator = coordinator
          return context
        
          // 7
        } else {
          println("Error adding persistent store at \(storeURL): \(error!) ")
        }
      
      } else {
        println("Error initializing model from: \(modelURL) ")
      }
    
    } else {
      println("Could not find data model in app bundle")
    }
    
    abort()
  
  }()
  

}

