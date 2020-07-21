//
//  AppDelegate.swift
//  AlterManager
//
//  Created by lvzhao on 2020/7/21.
//  Copyright © 2020 吕VV. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow()
        self.window?.backgroundColor = UIColor.white;
        self.window?.frame = UIScreen.main.bounds
        self.window?.makeKeyAndVisible()
            
              
              
        self.window?.rootViewController = ViewController()
              
        return true
    }



}

