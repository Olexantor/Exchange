//
//  AppDelegate.swift
//  Exchange
//
//  Created by Александр on 08.03.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = makeWindow()
        window?.makeKeyAndVisible()
        return true
    }
    
    func makeWindow() -> UIWindow {
        let vc = ExchangeScreenBuilder().build(.init(title: "EXCHANGE"))
        let window =  UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UINavigationController(rootViewController: vc)
        return window
    }
}

