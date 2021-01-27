//  Created by Bryan Keller on 1/26/21.
//  Copyright © 2021 Airbnb. All rights reserved.

import CoreGraphics

enum PaginationHelpers {
  
  static func closestPageIndex(forOffset offset: CGFloat, pageSize: CGFloat) -> Int {
    Int((offset / pageSize).rounded())
  }
  
  /// Returns the closest valid page offset to the target offset. This function is used when the horizontal pagination resting affinity is
  /// set to `.atPositionsClosestToTargetOffset`.
  static func closestPageOffset(
    toTargetOffset targetOffset: CGFloat,
    touchUpOffset: CGFloat,
    velocity: CGFloat,
    pageSize: CGFloat)
    -> CGFloat
  {
    let closestTargetPageIndex = closestPageIndex(forOffset: targetOffset, pageSize: pageSize)
    let proposedFinalOffset = CGFloat(closestTargetPageIndex) * pageSize

    if velocity > 0 && proposedFinalOffset < touchUpOffset {
      return proposedFinalOffset + pageSize
    } else if velocity < 0 && proposedFinalOffset > touchUpOffset {
      return proposedFinalOffset - pageSize
    } else {
      return proposedFinalOffset
    }
  }

  /// Returns the closest valid page offset to the current page. This function is used when the horizontal pagination resting affinity is
  /// set to `.atPositionsAdjacentToPrevious`.
  static func adjacentPageOffset(
    toPreviousPageIndex previousPageIndex: Int,
    targetOffset: CGFloat,
    velocity: CGFloat,
    pageSize: CGFloat)
    -> CGFloat
  {
    let closestTargetPageIndex = closestPageIndex(forOffset: targetOffset, pageSize: pageSize)
    
    let pageIndex: Int
    if velocity > 0 || closestTargetPageIndex > previousPageIndex {
      pageIndex = previousPageIndex + 1
    } else if velocity < 0 || closestTargetPageIndex < previousPageIndex  {
      pageIndex = previousPageIndex - 1
    } else {
      pageIndex = previousPageIndex
    }
    
    return CGFloat(pageIndex) * pageSize
  }
  
}
