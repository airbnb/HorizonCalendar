// Created by Bryan Keller on 2/6/21.
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

extension CalendarViewScrollPosition {
  
  func scrollPositionByConstrainingPaddingIfNeeded(
    itemSize: CGSize,
    viewportSize: CGSize,
    scrollAxis: ScrollAxis)
    -> Self
  {
    let _itemSize = itemSize
    let _viewportSize = viewportSize
    let itemSize: CGFloat
    let viewportSize: CGFloat
    switch scrollAxis {
    case .vertical:
      itemSize = _itemSize.height
      viewportSize = _viewportSize.height
    case .horizontal:
      itemSize = _itemSize.width
      viewportSize = _viewportSize.width
    }
    
    switch self {
    case .firstFullyVisiblePosition(let proposedPadding):
      let padding = constraintedPadding(
        proposedPadding: proposedPadding,
        itemSize: itemSize,
        viewportSize: viewportSize)
      return .firstFullyVisiblePosition(padding: padding)

    case .lastFullyVisiblePosition(let proposedPadding):
      let padding = constraintedPadding(
        proposedPadding: proposedPadding,
        itemSize: itemSize,
        viewportSize: viewportSize)
      return .lastFullyVisiblePosition(padding: padding)

    case .centered:
      return self
    }

  }
  
  private func constraintedPadding(
    proposedPadding: CGFloat,
    itemSize: CGFloat,
    viewportSize: CGFloat)
    -> CGFloat
  {
    // 1 less than the padding value that would be equivalent to `CalendarViewScrollPosition.center`
    let maximumPadding = (viewportSize / 2) - (itemSize / 2) - 1
    return max(0, min(maximumPadding, proposedPadding))
  }
  
}
