// Created by Bryan Keller on 8/21/20.
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

enum InternalAnyCalendarItemModel {

  case itemModel(AnyCalendarItemModel)
  case legacy(AnyCalendarItem)

  var itemViewDifferentiator: _CalendarItemViewDifferentiator {
    switch self {
    case .itemModel(let itemModel):
      return itemModel._itemViewDifferentiator
    case .legacy(let legacyItem):
      return .legacyReuseIdentifier(legacyItem.reuseIdentifier)
    }
  }

  var makeView: () -> UIView {
    switch self {
    case .itemModel(let itemModel):
      return itemModel._makeView
    case .legacy(let legacyItem):
      return legacyItem.buildView
    }
  }

  var setViewModelOnViewOfSameType: (UIView) -> Void {
    switch self {
    case .itemModel(let itemModel):
      return itemModel._setViewModel(onViewOfSameType:)
    case .legacy(let legacyItem):
      return legacyItem.updateViewModel(view:)
    }
  }

  var updateHighlightState: ((UIView, Bool) -> Void)? {
    switch self {
    case .itemModel:
      return nil
    case .legacy(let legacyItem):
      return legacyItem.updateHighlightState(view:isHighlighted:)
    }
  }

  func isViewModelEqualToViewModelOfOther(_ other: Self) -> Bool {
    switch (self, other) {
    case let (.itemModel(lhsItemModel), .itemModel(rhsItemModel)):
      return lhsItemModel._isViewModel(equalToViewModelOf: rhsItemModel)
    case let (.legacy(lhsLegacyItem), .legacy(rhsLegacyItem)):
      return lhsLegacyItem.isViewModel(equalToViewModelOf: rhsLegacyItem)
    default:
      return false
    }
  }

}
