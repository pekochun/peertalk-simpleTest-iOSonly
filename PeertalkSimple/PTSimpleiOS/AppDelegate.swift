//
//  AppDelegate.swift
//  PTSimpleiOS
//
//  Created by Kiran Kunigiri on 1/17/17.
//  Copyright © 2017 Kiran. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        PTManager.instance.connect(portNumber: PORT_NUMBER)
    }



}

