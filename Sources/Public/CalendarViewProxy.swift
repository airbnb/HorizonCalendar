// Created by Bryan Keller on 5/24/23.
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

import Foundation

/// A proxy type that enables a `CalendarViewRepresentable` to be programmatically scrolled. Initialize this type yourself from
/// your SwiftUI view as a `@StateObject`, and use it when initializing a `CalendarViewRepresentable`.
@available(iOS 13.0, *)
public final class CalendarViewProxy: ObservableObject {

  // MARK: Lifecycle

  public init() { }

  // MARK: Public

  /// The range of months that are partially or fully visible.
  public var visibleMonthRange: MonthComponentsRange? {
    calendarView.visibleMonthRange
  }

  /// The range of months that are partially or fully visible.
  public var visibleDayRange: DayComponentsRange? {
    calendarView.visibleDayRange
  }

  /// Scrolls the calendar to the specified month with the specified position.
  ///
  /// If the calendar has a non-zero frame, this function will scroll to the specified month immediately. Otherwise the scroll-to-month
  /// action will be queued and executed once the calendar has a non-zero frame. If this function is invoked multiple times before the
  /// calendar has a non-zero frame, only the most recent scroll-to-month action will be executed.
  ///
  /// - Parameters:
  ///   - dateInTargetMonth: A date in the target month to which to scroll into view.
  ///   - scrollPosition: The final position of the `CalendarView`'s scrollable region after the scroll completes.
  ///   - animated: Whether the scroll should be animated (from the current position), or whether the scroll should update the
  ///   visible region immediately with no animation.
  public func scrollToMonth(
    containing dateInTargetMonth: Date,
    scrollPosition: CalendarViewScrollPosition,
    animated: Bool)
  {
    calendarView.scroll(
      toMonthContaining: dateInTargetMonth,
      scrollPosition: scrollPosition,
      animated: animated)
  }

  /// Scrolls the calendar to the specified day with the specified position.
  ///
  /// If the calendar has a non-zero frame, this function will scroll to the specified day immediately. Otherwise the scroll-to-day action
  /// will be queued and executed once the calendar has a non-zero frame. If this function is invoked multiple times before the calendar
  /// has a non-zero frame, only the most recent scroll-to-day action will be executed.
  ///
  /// - Parameters:
  ///   - dateInTargetDay: A date in the target day to which to scroll into view.
  ///   - scrollPosition: The final position of the `CalendarView`'s scrollable region after the scroll completes.
  ///   - animated: Whether the scroll should be animated (from the current position), or whether the scroll should update the
  ///   visible region immediately with no animation.
  public func scrollToDay(
    containing dateInTargetDay: Date,
    scrollPosition: CalendarViewScrollPosition,
    animated: Bool)
  {
    calendarView.scroll(
      toDayContaining: dateInTargetDay,
      scrollPosition: scrollPosition,
      animated: animated)
  }

  // MARK: Internal

  var calendarView: CalendarView {
    guard let _calendarView else {
      fatalError("Attempted to use `CalendarViewProxy` before passing it to the `CalendarViewRepresentable` initializer.")
    }
    return _calendarView
  }

  weak var _calendarView: CalendarView? {
    didSet {
      if oldValue != nil, _calendarView != oldValue {
        fatalError("Attempted to use an existing `CalendarViewProxy` instance with a new `CalendarViewRepresentable`.")
      }
    }
  }

}
