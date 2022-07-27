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

import CoreGraphics
import UIKit.UIBezierPath

/// Represents a background or highlight layer shape; used by `DayView` and `DayOfWeekView`.
public enum Shape {
  case circle
  case rectangle(cornerRadius: CGFloat = 0)
  case custom((CGRect) -> UIBezierPath)
}

extension Shape: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .circle:
      break
    case .rectangle(let cornerRadius):
      hasher.combine(cornerRadius)
    case .custom:
      break
    }
  }
}

extension Shape: Equatable {
  public static func == (lhs: Shape, rhs: Shape) -> Bool {
    switch (lhs, rhs) {
    case (.circle, .circle):
      return true
    case (.rectangle, .rectangle):
      return true
    case (.custom, .custom):
      return true
    default:
      return false
    }
  }
}
