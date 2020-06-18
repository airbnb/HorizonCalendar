// Created by Bryan Keller on 3/29/20.
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

// MARK: - LayoutItem

/// Represents an item that's used to build the base layout of the calendar.
struct LayoutItem {
  let itemType: ItemType
  let frame: CGRect
}

// MARK: - LayoutItem.ItemType

extension LayoutItem {

  enum ItemType: Equatable, Hashable {

    case monthHeader(Month)
    case dayOfWeekInMonth(position: DayOfWeekPosition, month: Month)
    case day(Day)

    var month: Month {
      switch self {
      case .monthHeader(let month): return month
      case .dayOfWeekInMonth(_, let month): return month
      case .day(let day): return day.month
      }
    }

  }

}

// MARK: Comparable

extension LayoutItem.ItemType: Comparable {

  static func < (lhs: LayoutItem.ItemType, rhs: LayoutItem.ItemType) -> Bool {
    switch (lhs, rhs) {
    case let (.monthHeader(lhsMonth), .monthHeader(rhsMonth)):
      return lhsMonth < rhsMonth
    case let (.monthHeader(lhsMonth), .dayOfWeekInMonth(_, rhsMonth)):
      return lhsMonth <= rhsMonth
    case let (.monthHeader(lhsMonth), .day(rhsDay)):
      return lhsMonth <= rhsDay.month

    case let (
      .dayOfWeekInMonth(lhsPosition, lhsMonth),
      .dayOfWeekInMonth(rhsPosition, rhsMonth)):
      return lhsMonth < rhsMonth || (lhsMonth == rhsMonth && lhsPosition < rhsPosition)
    case let (.dayOfWeekInMonth(_, lhsMonth), .monthHeader(rhsMonth)):
      return lhsMonth < rhsMonth
    case let (.dayOfWeekInMonth(_, lhsMonth), .day(rhsDay)):
      return lhsMonth <= rhsDay.month

    case let (.day(lhsDay), .day(rhsDay)):
      return lhsDay < rhsDay
    case let (.day(lhsDay), .monthHeader(rhsMonth)):
      return lhsDay.month < rhsMonth
    case let (.day(lhsDay), .dayOfWeekInMonth(_, rhsMonth)):
      return lhsDay.month < rhsMonth
    }
  }

}
