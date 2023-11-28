// Created by bryan_keller on 11/27/23.
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

/// A scroll view with altered behavior to better fit the needs of `CalendarView`.
///
/// - Forces `contentInsetAdjustmentBehavior == .never`.
///   - The main thing this prevents is the situation where the view hierarchy is traversed to find a scroll view, and attempts are made to
///     change that scroll view's `contentInsetAdjustmentBehavior`.
/// - Customizes the accessibility elements of the scroll view
final class CalendarScrollView: UIScrollView {

  // MARK: Lifecycle

  init() {
    super.init(frame: .zero)
    contentInsetAdjustmentBehavior = .never
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  var cachedAccessibilityElements: [Any]?

  override var contentInsetAdjustmentBehavior: ContentInsetAdjustmentBehavior {
    didSet {
      super.contentInsetAdjustmentBehavior = .never
    }
  }

  override var isAccessibilityElement: Bool {
    get { false }
    set { }
  }

  override var accessibilityElements: [Any]? {
    get {
      guard let itemViews = subviews as? [ItemView] else {
        fatalError("Only `ItemView`s can be used as subviews of the scroll view.")
      }
      cachedAccessibilityElements = cachedAccessibilityElements ?? itemViews
        .filter {
          switch $0.itemType {
          case .layoutItemType:
            return true
          default:
            return false
          }
        }
        .sorted {
          guard
            case .layoutItemType(let lhsItemType) = $0.itemType,
            case .layoutItemType(let rhsItemType) = $1.itemType
          else {
            fatalError("Cannot sort views for Voice Over that aren't layout items.")
          }
          return lhsItemType < rhsItemType
        }

      return cachedAccessibilityElements
    }
    set { }
  }

}
