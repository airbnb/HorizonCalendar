// Created by Bryan Keller on 2/2/23.
// Copyright © 2023 Airbnb Inc. All rights reserved.

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

/// Used to configure the days-of-the-week row's separator.
public struct DaysOfTheWeekRowSeparatorOptions: Hashable {

  // MARK: Lifecycle

  /// Initialized a new `DaysOfTheWeekRowSeparatorOptions`.
  ///
  /// - Parameters:
  ///   - height: The height of the separator in points.
  ///   - color: The color of the separator.
  public init(height: CGFloat = 1, color: UIColor = .lightGray) {
    self.height = height
    self.color = color
  }

  // MARK: Public

  @available(iOS 13.0, *)
  public static var systemStyleSeparator = DaysOfTheWeekRowSeparatorOptions(
    height: 1,
    color: .separator)

  /// The height of the separator in points.
  public var height: CGFloat

  /// The color of the separator.
  public var color: UIColor
}
