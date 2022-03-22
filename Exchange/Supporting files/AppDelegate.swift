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
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.rootViewController = UINavigationController(rootViewController: ExchangeViewController())
//        window?.rootViewController = UINavigationController(rootViewController: ExchangeScreenBuilder().build(.init(title: "Exchange")))
//        window?.rootViewController = UINavigationController(rootViewController: TestScreenBuilder().build(.init(message: "Hi")))
        return true
    }
    
    func makeWindow() -> UIWindow {
        let vc = ExchangeScreenBuilder().build(.init(title: "Exchange"))
    }
//    let vc = ExchangeScreenBuilder().builder()
    
}

