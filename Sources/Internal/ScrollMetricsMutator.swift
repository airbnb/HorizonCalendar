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

  init(scrollMetricsProvider: ScrollMetricsProvider, scrollAxis: ScrollAxis) {
    self.scrollMetricsProvider = scrollMetricsProvider
    self.scrollAxis = scrollAxis
  }

  // MARK: Internal

  let scrollAxis: ScrollAxis

  func setUpInitialMetricsIfNeeded() {
    guard !hasSetUpInitialScrollMetrics else { return }

    scrollMetricsProvider.setStartInset(to: 0, for: .horizontal)
    scrollMetricsProvider.setStartInset(to: 0, for: .vertical)

    scrollMetricsProvider.setSize(to: Self.contentSize, for: scrollAxis)
    scrollMetricsProvider.setOffset(to: Self.minimumContentOffset, for: scrollAxis)

    scrollMetricsProvider.setEndInset(to: 0, for: .horizontal)
    scrollMetricsProvider.setEndInset(to: 0, for: .vertical)

    hasSetUpInitialScrollMetrics = true
  }

  func updateContentSizePerpendicularToScrollAxis(viewportSize: CGSize) {
    switch scrollAxis {
    case .vertical:
      scrollMetricsProvider.setSize(to: viewportSize.width, for: .horizontal)
    case .horizontal:
      scrollMetricsProvider.setSize(to: viewportSize.height, for: .vertical)
    }
  }

  func updateScrollBoundaries(minimumScrollOffset: CGFloat?, maximumScrollOffset: CGFloat?) {
    let originalOffset = scrollMetricsProvider.offset(for: scrollAxis)

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

    // If we don't backup and restore the offset, one-frame glitches / scroll position jumps can
    // occur if both `minimumScrollOffset` and `maximumScrollOffset` go from both being set to only
    // one being set.
    scrollMetricsProvider.setOffset(to: originalOffset, for: scrollAxis)
  }

  func loopOffsetIfNeeded(updatingPositionOf layoutItem: LayoutItem) -> LayoutItem {
    var origin = layoutItem.frame.origin

    let offset = scrollMetricsProvider.offset(for: scrollAxis)
    let startInset = scrollMetricsProvider.startInset(for: scrollAxis)
    let endInset = scrollMetricsProvider.endInset(for: scrollAxis)

    if offset < Self.minimumContentOffset && startInset == 0 {
      scrollMetricsProvider.setOffset(to: Self.maximumContentOffset, for: scrollAxis)

      switch scrollAxis {
      case .vertical: origin.y += Self.loopingRegionSize
      case .horizontal: origin.x += Self.loopingRegionSize
      }
    } else if offset > Self.maximumContentOffset && endInset == 0 {
      scrollMetricsProvider.setOffset(to: Self.minimumContentOffset, for: scrollAxis)

      switch scrollAxis {
      case .vertical: origin.y -= Self.loopingRegionSize
      case .horizontal: origin.x -= Self.loopingRegionSize
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

  private static let contentSize: CGFloat = 30_000 // 10,000 padding from min and max offset
  private static let minimumContentOffset: CGFloat = 10_000 // 1/3 of content size
  private static let maximumContentOffset: CGFloat = 20_000 // 2/3 of content size
  private static let loopingRegionSize: CGFloat = 10_000 // Distance between min and max offset

  private let scrollMetricsProvider: ScrollMetricsProvider

  private var hasSetUpInitialScrollMetrics = false

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
