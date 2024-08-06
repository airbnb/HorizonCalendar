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

  func reusedViewContexts(
    visibleItems: Set<VisibleItem>,
    reuseUnusedViews: Bool)
    -> [ReusedViewContext]
  {
    var contexts = [ReusedViewContext]()

    var previousViewsForVisibleItems = viewsForVisibleItems
    viewsForVisibleItems.removeAll(keepingCapacity: true)

    for visibleItem in visibleItems {
      let viewDifferentiator = visibleItem.calendarItemModel._itemViewDifferentiator

      let context: ReusedViewContext =
        if let view = previousViewsForVisibleItems.removeValue(forKey: visibleItem)
      {
        ReusedViewContext(
          view: view,
          visibleItem: visibleItem,
          isViewReused: true,
          isReusedViewSameAsPreviousView: true)
      } else if !(unusedViewsForViewDifferentiators[viewDifferentiator]?.isEmpty ?? true) {
        ReusedViewContext(
          view: unusedViewsForViewDifferentiators[viewDifferentiator]!.remove(at: 0),
          visibleItem: visibleItem,
          isViewReused: true,
          isReusedViewSameAsPreviousView: false)
      } else {
        ReusedViewContext(
          view: ItemView(initialCalendarItemModel: visibleItem.calendarItemModel),
          visibleItem: visibleItem,
          isViewReused: false,
          isReusedViewSameAsPreviousView: false)
      }

      contexts.append(context)

      viewsForVisibleItems[visibleItem] = context.view
    }

    if reuseUnusedViews {
      for (visibleItem, unusedView) in previousViewsForVisibleItems {
        let viewDifferentiator = visibleItem.calendarItemModel._itemViewDifferentiator
        unusedViewsForViewDifferentiators[viewDifferentiator, default: .init()].append(unusedView)
      }
    }

    return contexts
  }

  // MARK: Private

  private var viewsForVisibleItems = [VisibleItem: ItemView]()
  private var unusedViewsForViewDifferentiators = [_CalendarItemViewDifferentiator: [ItemView]]()

}

// MARK: - ReusedViewContext

struct ReusedViewContext {
  let view: ItemView
  let visibleItem: VisibleItem
  let isViewReused: Bool
  let isReusedViewSameAsPreviousView: Bool
}
