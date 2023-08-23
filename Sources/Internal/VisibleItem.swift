// Created by Bryan Keller on 1/29/20.
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

import CoreGraphics

// MARK: - VisibleItem

/// Represents any visible item in the calendar, ranging from core layout items like month headers and days, to secondary items like
/// day range items and overlay items.
///
/// - Note: This is a reference type because it's heavily used in `Set`s, especially in the reuse manager. By making it a reference
/// type, we avoid `VisibleItem` `initializeWithCopy` when mutating the `Set`s. This type also caches its hash
/// value, which otherwise would be recomputed for every `Set` operation performed by the reuse manager. On an iPhone 6s, this
/// reduces CPU usage by nearly 10% when programmatically scrolling down at a rate of 500 points / frame.
final class VisibleItem {

  // MARK: Lifecycle

  init(calendarItemModel: AnyCalendarItemModel, itemType: ItemType, frame: CGRect) {
    self.calendarItemModel = calendarItemModel
    self.itemType = itemType
    self.frame = frame

    var hasher = Hasher()
    hasher.combine(calendarItemModel._itemViewDifferentiator)
    hasher.combine(itemType)
    cachedHashValue = hasher.finalize()
  }

  // MARK: Internal

  let calendarItemModel: AnyCalendarItemModel
  let itemType: ItemType
  let frame: CGRect

  // MARK: Private

  // Performance optimization - storing this separately speeds up the `Hashable` implementation,
  // which is frequently invoked by the `ItemViewReuseManager`'s `Set` operations.
  private let cachedHashValue: Int

}

// MARK: Equatable

extension VisibleItem: Equatable {

  static func == (lhs: VisibleItem, rhs: VisibleItem) -> Bool {
    lhs.calendarItemModel._itemViewDifferentiator == rhs.calendarItemModel._itemViewDifferentiator &&
      lhs.itemType == rhs.itemType
  }

}

// MARK: Hashable

extension VisibleItem: Hashable {

  func hash(into hasher: inout Hasher) {
    hasher.combine(cachedHashValue)
  }

}

// MARK: - VisibleItem.ItemType

extension VisibleItem {

  enum ItemType: Equatable, Hashable {
    case layoutItemType(LayoutItem.ItemType)
    case dayBackground(Day)
    case monthBackground(Month)
    case pinnedDayOfWeek(DayOfWeekPosition)
    case pinnedDaysOfWeekRowBackground
    case pinnedDaysOfWeekRowSeparator
    case daysOfWeekRowSeparator(Month)
    case dayRange(DayRange)
    case overlayItem(OverlaidItemLocation)
  }

}
