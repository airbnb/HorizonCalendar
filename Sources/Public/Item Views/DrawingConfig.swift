// Created by Bryan Keller on 9/12/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

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

/// A configuration used when creating a background or highlight layer; used by `DayView` and `DayOfWeekView`.
public struct DrawingConfig: Hashable {

  // MARK: Lifecycle

  public init(
    fillColor: UIColor = .clear,
    borderColor: UIColor = .clear,
    borderWidth: CGFloat = 1)
  {
    self.fillColor = fillColor
    self.borderColor = borderColor
    self.borderWidth = borderWidth
  }

  // MARK: Public

  public static let transparent = DrawingConfig()

  public var fillColor = UIColor.clear
  public var borderColor = UIColor.clear
  public var borderWidth: CGFloat = 1
}
