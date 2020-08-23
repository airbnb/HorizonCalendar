// Created by Bryan Keller on 4/18/20.
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

// MARK: OffScreenCalendarItemAccessibilityElement

/// An accessibility element for an off-screen item that mirrors the accessibility traits and label of its corresponding item's view.
final class OffScreenCalendarItemAccessibilityElement: UIAccessibilityElement {

  // MARK: Lifecycle

  init?(correspondingItem: VisibleCalendarItem, scrollViewContainer: UIScrollView) {
    let view = correspondingItem.calendarItemModel.makeView()
    correspondingItem.calendarItemModel.setViewModelOnViewOfSameType(view)
    guard view.isAccessibilityElement else { return nil }

    self.correspondingItem = correspondingItem

    super.init(accessibilityContainer: scrollViewContainer)

    accessibilityTraits = view.accessibilityTraits
    accessibilityLabel = view.accessibilityLabel
  }

  // MARK: Internal

  let correspondingItem: VisibleCalendarItem

}
