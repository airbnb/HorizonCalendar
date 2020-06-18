// Created by Bryan Keller on 3/24/20.
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

// MARK: - ScrollMetricsMutator

/// Facilitates infinite scrolling by looping the scroll position until an edge is hit.
final class ScrollMetricsMutator {

  // MARK: Lifecycle

  init(scrollMetricsProvider: ScrollMetricsProvider, bounds: CGRect, scrollAxis: ScrollAxis) {
    self.scrollMetricsProvider = scrollMetricsProvider
    self.bounds = bounds
    self.scrollAxis = scrollAxis
  }

  // MARK: Internal

  let bounds: CGRect
  let scrollAxis: ScrollAxis

  func setUpInitialMetricsIfNeeded() {
    guard !hasSetUpInitialScrollMetrics else { return }

    scrollMetricsProvider.setStartInset(to: 0, for: .horizontal)
    scrollMetricsProvider.setStartInset(to: 0, for: .vertical)

    scrollMetricsProvider.setEndInset(to: 0, for: .horizontal)
    scrollMetricsProvider.setEndInset(to: 0, for: .vertical)

    let size: CGFloat
    switch scrollAxis {
    case .vertical:
      size = bounds.height
      scrollMetricsProvider.setSize(to: bounds.width, for: .horizontal)
    case .horizontal:
      size = bounds.width
      scrollMetricsProvider.setSize(to: bounds.height, for: .vertical)
    }

    scrollMetricsProvider.setSize(to: size * Self.contentSizeMultiplier, for: scrollAxis)
    scrollMetricsProvider.setOffset(to: minimumContentOffset, for: scrollAxis)

    hasSetUpInitialScrollMetrics = true
  }

  func updateScrollBoundaries(minimumScrollOffset: CGFloat?, maximumScrollOffset: CGFloat?) {
    if let minimumScrollOffset = minimumScrollOffset {
      scrollMetricsProvider.setStartInset(to: -minimumScrollOffset, for: scrollAxis)
    } else {
      scrollMetricsProvider.setStartInset(to: 0, for: scrollAxis)
    }

    if let maximumScrollOffset = maximumScrollOffset {
      let size = scrollMetricsProvider.size(for: scrollAxis)
      scrollMetricsProvider.setEndInset(to: -(size - maximumScrollOffset), for: scrollAxis)
    } else {
      scrollMetricsProvider.setEndInset(to: 0, for: scrollAxis)
    }
  }

  func loopOffsetIfNeeded(updatingPositionOf layoutItem: LayoutItem) -> LayoutItem {
    var origin = layoutItem.frame.origin

    let offset = scrollMetricsProvider.offset(for: scrollAxis)
    let startInset = scrollMetricsProvider.startInset(for: scrollAxis)
    let endInset = scrollMetricsProvider.endInset(for: scrollAxis)

    if offset < minimumContentOffset && startInset == 0 {
      scrollMetricsProvider.setOffset(to: maximumContentOffset, for: scrollAxis)

      switch scrollAxis {
      case .vertical: origin.y += loopingRegionSize
      case .horizontal: origin.x += loopingRegionSize
      }
    } else if offset > maximumContentOffset && endInset == 0 {
      scrollMetricsProvider.setOffset(to: minimumContentOffset, for: scrollAxis)

      switch scrollAxis {
      case .vertical: origin.y -= loopingRegionSize
      case .horizontal: origin.x -= loopingRegionSize
      }
    }

    return LayoutItem(
      itemType: layoutItem.itemType,
      frame: CGRect(origin: origin, size: layoutItem.frame.size))
  }

  func applyOffset(_ offset: CGFloat) {
    let currentOffset = scrollMetricsProvider.offset(for: scrollAxis)
    scrollMetricsProvider.setOffset(to: currentOffset + offset, for: scrollAxis)
  }

  // MARK: Private

  /// A content size multiplier of 15 is large enough to prevent a high-velocity scroll from causing us to bump into an edge prematurely.
  private static let contentSizeMultiplier: CGFloat = 15
  private static let loopingRegionSizeDeterminingMultiplier: CGFloat = 1 / 3

  private let scrollMetricsProvider: ScrollMetricsProvider

  private var hasSetUpInitialScrollMetrics = false

  private var minimumContentOffset: CGFloat {
    scrollMetricsProvider.size(for: scrollAxis) * Self.loopingRegionSizeDeterminingMultiplier
  }

  private var maximumContentOffset: CGFloat {
    scrollMetricsProvider.size(for: scrollAxis) * 2 * Self.loopingRegionSizeDeterminingMultiplier
  }

  private var loopingRegionSize: CGFloat {
    scrollMetricsProvider.size(for: scrollAxis) * Self.loopingRegionSizeDeterminingMultiplier
  }

}

// MARK: - ScrollAxis

enum ScrollAxis {
  case vertical
  case horizontal
}

// MARK: - ScrollMetricsProvider

protocol ScrollMetricsProvider: class {

  func size(for scrollAxis: ScrollAxis) -> CGFloat
  func setSize(to size: CGFloat, for scrollAxis: ScrollAxis)

  func offset(for scrollAxis: ScrollAxis) -> CGFloat
  func setOffset(to offset: CGFloat, for scrollAxis: ScrollAxis)

  func startInset(for scrollAxis: ScrollAxis) -> CGFloat
  func setStartInset(to inset: CGFloat, for scrollAxis: ScrollAxis)

  func endInset(for scrollAxis: ScrollAxis) -> CGFloat
  func setEndInset(to inset: CGFloat, for scrollAxis: ScrollAxis)

}

// MARK: UIScrollView+ScrollMetricsProvider

extension UIScrollView: ScrollMetricsProvider {

  func size(for scrollAxis: ScrollAxis) -> CGFloat {
    switch scrollAxis {
    case .vertical: return contentSize.height
    case .horizontal: return contentSize.width
    }
  }

  func setSize(to size: CGFloat, for scrollAxis: ScrollAxis) {
    switch scrollAxis {
    case .vertical: contentSize.height = size
    case .horizontal: contentSize.width = size
    }
  }

  func offset(for scrollAxis: ScrollAxis) -> CGFloat {
    switch scrollAxis {
    case .vertical: return contentOffset.y
    case .horizontal: return contentOffset.x
    }
  }

  func setOffset(to offset: CGFloat, for scrollAxis: ScrollAxis) {
    switch scrollAxis {
    case .vertical: contentOffset.y = offset
    case .horizontal: contentOffset.x = offset
    }
  }

  func startInset(for scrollAxis: ScrollAxis) -> CGFloat {
    switch scrollAxis {
    case .vertical: return contentInset.top
    case .horizontal: return contentInset.left
    }
  }

  func setStartInset(to inset: CGFloat, for scrollAxis: ScrollAxis) {
    switch scrollAxis {
    case .vertical: contentInset.top = inset
    case .horizontal: contentInset.left = inset
    }
  }

  func endInset(for scrollAxis: ScrollAxis) -> CGFloat {
    switch scrollAxis {
    case .vertical: return contentInset.bottom
    case .horizontal: return contentInset.right
    }
  }

  func setEndInset(to inset: CGFloat, for scrollAxis: ScrollAxis) {
    switch scrollAxis {
    case .vertical: contentInset.bottom = inset
    case .horizontal: contentInset.right = inset
    }
  }

}
