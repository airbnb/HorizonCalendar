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

import UIKit

// MARK: - CalendarItemViewReuseManager

/// Facilitates the reuse of `CalendarItemView`s to prevent new views being allocated when an existing view of the same type
/// already exists and is off screen / available to be used in a different location.
final class CalendarItemViewReuseManager {

  // MARK: Internal

  func viewsForVisibleItems(
    _ visibleItems: Set<VisibleCalendarItem>,
    viewHandler: (
      CalendarItemView,
      VisibleCalendarItem,
      _ previousBackingVisibleItem: VisibleCalendarItem?)
      -> Void)
  {
    var visibleItemsDifferencesForReuseIDs = [String: Set<VisibleCalendarItem>]()

    // For each reuse ID, track the difference between the new set of visible items and the previous
    // set of visible items. The remaining previous visible items after subtracting the current
    // visible items are the previously visible items that aren't currently visible, and are
    // therefore free to be reused.
    for visibleItem in visibleItems {
      let reuseID = visibleItem.calendarItem.reuseIdentifier

      var visibleItemsDifference: Set<VisibleCalendarItem>
      if let difference = visibleItemsDifferencesForReuseIDs[reuseID] {
        visibleItemsDifference = difference
      } else if let previouslyVisibleItems = visibleItemsForReuseIDs[reuseID] {
        visibleItemsDifference = previouslyVisibleItems.subtracting(visibleItems)
      } else {
        visibleItemsDifference = []
      }

      let context = reusedViewContext(
        for: visibleItem,
        unusedPreviouslyVisibleItems: &visibleItemsDifference)
      viewHandler(context.view, visibleItem, context.previousBackingVisibleItem)

      visibleItemsDifferencesForReuseIDs[reuseID] = visibleItemsDifference
    }
  }

  // MARK: Private

  private var visibleItemsForReuseIDs = [String: Set<VisibleCalendarItem>]()
  private var viewsForVisibleItems = [VisibleCalendarItem: CalendarItemView]()

  private func reusedViewContext(
    for visibleItem: VisibleCalendarItem,
    unusedPreviouslyVisibleItems: inout Set<VisibleCalendarItem>)
    -> ReusedViewContext
  {
    let reuseID = visibleItem.calendarItem.reuseIdentifier

    let view: CalendarItemView
    let previousBackingVisibleItem: VisibleCalendarItem?

    if let previouslyVisibleItems = visibleItemsForReuseIDs[reuseID] {
      if previouslyVisibleItems.contains(visibleItem) {
        // New visible item was also an old visible item, so we can just use the same view again.

        guard let previousView = viewsForVisibleItems[visibleItem] else {
          preconditionFailure("""
            `viewsForVisibleItems` must have a key for every member in
            `visibleItemsForReuseIDs`'s values.
          """)
        }

        view = previousView
        previousBackingVisibleItem = visibleItem

        visibleItemsForReuseIDs[reuseID]?.remove(visibleItem)
        viewsForVisibleItems.removeValue(forKey: visibleItem)
      } else {
        if let previouslyVisibleItem = unusedPreviouslyVisibleItems.first {
          // An unused, previously-visible item is available, so reuse it.

          guard let previousView = viewsForVisibleItems[previouslyVisibleItem] else {
            preconditionFailure("""
              `viewsForVisibleItems` must have a key for every member in
              `visibleItemsForReuseIDs`'s values.
            """)
          }

          view = previousView
          previousBackingVisibleItem = previouslyVisibleItem

          unusedPreviouslyVisibleItems.remove(previouslyVisibleItem)

          visibleItemsForReuseIDs[reuseID]?.remove(previouslyVisibleItem)
          viewsForVisibleItems.removeValue(forKey: previouslyVisibleItem)
        } else {
          // No previously-visible item is available for reuse, so create a new view.
          view = CalendarItemView(initialCalendarItem: visibleItem.calendarItem)
          previousBackingVisibleItem = nil
        }
      }
    }
    else {
      // No previously-visible item is available for reuse, so create a new view.
      view = CalendarItemView(initialCalendarItem: visibleItem.calendarItem)
      previousBackingVisibleItem = nil
    }

    visibleItemsForReuseIDs[reuseID] = visibleItemsForReuseIDs[reuseID] ?? []
    visibleItemsForReuseIDs[reuseID]?.insert(visibleItem)
    viewsForVisibleItems[visibleItem] = view

    return ReusedViewContext(view: view, previousBackingVisibleItem: previousBackingVisibleItem)
  }

}

// MARK: - ReusedViewContext

private struct ReusedViewContext {
  let view: CalendarItemView
  let previousBackingVisibleItem: VisibleCalendarItem?
}
