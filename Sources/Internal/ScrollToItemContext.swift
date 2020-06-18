// Created by Bryan Keller on 4/22/20.
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

// MARK: - ScrollToItemContext

struct ScrollToItemContext {
  let targetItem: TargetItem
  let scrollPosition: CalendarViewScrollPosition
  let animated: Bool
}

// MARK: - ScrollToItemContext.TargetItem

extension ScrollToItemContext {

  enum TargetItem {
    case month(Month)
    case day(Day)
  }

}

// MARK: - ScrollToItemContext.PositionRelativeToVisibleBounds

extension ScrollToItemContext {

  enum PositionRelativeToVisibleBounds {
    case before
    case after
    case partiallyOrFullyVisible(frame: CGRect)
  }

}
