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

// MARK: - ItemViewReuseManager

/// Facilitates the reuse of `ItemView`s to prevent new views being allocated when an existing view of the same type
/// already exists and is off screen / available to be used in a different location.
final class ItemViewReuseManager {

  // MARK: Internal

  func viewsForVisibleItems(
    _ visibleItems: Set<VisibleItem>,
    viewHandler: (
      ItemView,
      VisibleItem,
      _ previousBackingVisibleItem: VisibleItem?,
      _ isReusedViewSameAsPreviousView: Bool)
      -> Void)
  {
    var visibleItemsDifferencesItemViewDifferentiators = [
      _CalendarItemViewDifferentiator: Set<VisibleItem>
    ]()

    // For each reuse ID, track the difference between the new set of visible items and the previous
    // set of visible items. The remaining previous visible items after subtracting the current
    // visible items are the previously visible items that aren't currently visible, and are
    // therefore free to be reused.
    for visibleItem in visibleItems {
      let differentiator = visibleItem.calendarItemModel._itemViewDifferentiator

      var visibleItemsDifference: Set<VisibleItem>
      if let difference = visibleItemsDifferencesItemViewDifferentiators[differentiator] {
        visibleItemsDifference = difference
      } else if
        let previouslyVisibleItems = visibleItemsForItemViewDifferentiators[differentiator]
      {
        visibleItemsDifference = previouslyVisibleItems.subtracting(visibleItems)
      } else {
        visibleItemsDifference = []
      }

      let context = reusedViewContext(
        for: visibleItem,
        unusedPreviouslyVisibleItems: &visibleItemsDifference)
      viewHandler(
        context.view,
        visibleItem,
        context.previousBackingVisibleItem,
        context.isReusedViewSameAsPreviousView)

      visibleItemsDifferencesItemViewDifferentiators[differentiator] = visibleItemsDifference
    }
  }

  // MARK: Private

  private var visibleItemsForItemViewDifferentiators = [
    _CalendarItemViewDifferentiator: Set<VisibleItem>
  ]()
  private var viewsForVisibleItems = [VisibleItem: ItemView]()

  private func reusedViewContext(
    for visibleItem: VisibleItem,
    unusedPreviouslyVisibleItems: inout Set<VisibleItem>)
    -> ReusedViewContext
  {
    let differentiator = visibleItem.calendarItemModel._itemViewDifferentiator

    let view: ItemView
    let previousBackingVisibleItem: VisibleItem?
    let isReusedViewSameAsPreviousView: Bool

    if let previouslyVisibleItems = visibleItemsForItemViewDifferentiators[differentiator] {
      if previouslyVisibleItems.contains(visibleItem) {
        // New visible item was also an old visible item, so we can just use the same view again.

        guard let previousView = viewsForVisibleItems[visibleItem] else {
          preconditionFailure("""
            `viewsForVisibleItems` must have a key for every member in
            `visibleItemsForItemViewDifferentiators`'s values.
          """)
        }

        view = previousView
        previousBackingVisibleItem = visibleItem
        isReusedViewSameAsPreviousView = true

        visibleItemsForItemViewDifferentiators[differentiator]?.remove(visibleItem)
        viewsForVisibleItems.removeValue(forKey: visibleItem)
      } else {
        if let previouslyVisibleItem = unusedPreviouslyVisibleItems.first {
          // An unused, previously-visible item is available, so reuse it.

          guard let previousView = viewsForVisibleItems[previouslyVisibleItem] else {
            preconditionFailure("""
              `viewsForVisibleItems` must have a key for every member in
              `visibleItemsForItemViewDifferentiators`'s values.
            """)
          }

          view = previousView
          previousBackingVisibleItem = previouslyVisibleItem
          isReusedViewSameAsPreviousView = false

          unusedPreviouslyVisibleItems.remove(previouslyVisibleItem)

          visibleItemsForItemViewDifferentiators[differentiator]?.remove(previouslyVisibleItem)
          viewsForVisibleItems.removeValue(forKey: previouslyVisibleItem)
        } else {
          // No previously-visible item is available for reuse, so create a new view.
          view = ItemView(initialCalendarItemModel: visibleItem.calendarItemModel)
          previousBackingVisibleItem = nil
          isReusedViewSameAsPreviousView = false
        }
      }
    }
    else {
      // No previously-visible item is available for reuse, so create a new view.
      view = ItemView(initialCalendarItemModel: visibleItem.calendarItemModel)
      previousBackingVisibleItem = nil
      isReusedViewSameAsPreviousView = false
    }

    let newVisibleItems = visibleItemsForItemViewDifferentiators[differentiator] ?? []
    visibleItemsForItemViewDifferentiators[differentiator] = newVisibleItems
    visibleItemsForItemViewDifferentiators[differentiator]?.insert(visibleItem)
    viewsForVisibleItems[visibleItem] = view

    return ReusedViewContext(
      view: view,
      previousBackingVisibleItem: previousBackingVisibleItem,
      isReusedViewSameAsPreviousView: isReusedViewSameAsPreviousView)
  }

}

// MARK: - ReusedViewContext

private struct ReusedViewContext {
  let view: ItemView
  let previousBackingVisibleItem: VisibleItem?
  let isReusedViewSameAsPreviousView: Bool
}
