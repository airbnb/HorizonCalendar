// Created by Bryan Keller on 7/21/23.
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

// MARK: - VisibleMonthHeaderHeightTracker

/// Calculates heights for month headers by self-sizing views on the fly. Sizing views are reused to prevent unnecessary view allocations.
final class VisibleMonthHeaderHeightTracker {

  // MARK: Lifecycle

  init(content: CalendarViewContent, size: CGSize, reuseManager: ItemViewReuseManager) {
    self.content = content
    self.size = size
    self.reuseManager = reuseManager
  }

  // MARK: Internal

  func monthHeaderHeight(for month: Month) -> CGFloat {
    let monthHeaderHeight = monthHeaderHeightsForMonths.value(
      for: month,
      missingValueProvider: {
        let monthHeaderItemModel = content.monthHeaderItemProvider(month)
        let visibleItem = VisibleItem(
          calendarItemModel: monthHeaderItemModel,
          itemType: .layoutItemType(.monthHeader(month)),
          frame: .zero)
        var itemView: ItemView?
        reuseManager.viewsForVisibleItems([visibleItem], viewHandler: { _itemView, visibleItem, _, _ in
          _itemView.calendarItemModel = visibleItem.calendarItemModel
          _itemView.itemType = visibleItem.itemType
          itemView = _itemView
        })

        guard let itemView else {
          fatalError("Failed to get a sizing month header view for month \(month).")
        }

        let monthWidth: CGFloat
        switch content.monthsLayout {
        case .vertical:
          monthWidth = size.width
        case .horizontal(let options):
          monthWidth = options.monthWidth(
            calendarWidth: size.width,
            interMonthSpacing: content.interMonthSpacing)
        }

        let size = itemView.contentView.systemLayoutSizeFitting(
          CGSize(width: monthWidth, height: UIView.layoutFittingCompressedSize.height),
          withHorizontalFittingPriority: .required,
          verticalFittingPriority: .fittingSizeLevel)

        return size.height
      })

    return monthHeaderHeight
  }

  // MARK: Private

  private let content: CalendarViewContent
  private let size: CGSize
  private let reuseManager: ItemViewReuseManager

  private var monthHeaderHeightsForMonths = [Month: CGFloat]()

}
