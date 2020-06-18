// Created by Bryan Keller on 5/31/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

// MARK: - AppDelegate

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

  // MARK: Internal

  var window: UIWindow?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
    -> Bool
  {
    window = UIWindow(frame: UIScreen.main.bounds)
    let demoPickerViewController = DemoPickerViewController()
    let navigationController = UINavigationController(rootViewController: demoPickerViewController)
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
    return true
  }

}

