// Created by Bryan Keller on 10/3/19.
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

extension CGFloat {

  /// Rounds `self` so that it's aligned on a pixel boundary for a screen with the provided scale.
  func alignedToPixel(forScreenWithScale scale: CGFloat) -> CGFloat {
    (self * scale).rounded() / scale
  }
  
  /// Tests `self` for approximate equality using the threshold value. For example, 1.48 equals 1.52 if the threshold is 0.05.
  /// `threshold` will be treated as a postive value by taking its absolute value.
  func isEqual(to rhs: CGFloat, threshhold: CGFloat) -> Bool {
    abs(self - rhs) <= abs(threshhold)
  }

}

extension CGRect {

  /// Rounds a `CGRect`'s `origin` and `size` values so that they're aligned on pixel boundaries for a screen with the provided
  /// scale.
  func alignedToPixels(forScreenWithScale scale: CGFloat) -> CGRect {
    let alignedX = minX.alignedToPixel(forScreenWithScale: scale)
    let alignedY = minY.alignedToPixel(forScreenWithScale: scale)
    return CGRect(
      x: alignedX,
      y: alignedY,
      width: maxX.alignedToPixel(forScreenWithScale: scale) - alignedX,
      height: maxY.alignedToPixel(forScreenWithScale: scale) - alignedY)
  }

}

extension CGPoint {

  /// Rounds a `CGPoints`'s `x` and `y` values so that they're aligned on pixel boundaries for a screen with the provided scale.
  func alignedToPixels(forScreenWithScale scale: CGFloat) -> CGPoint {
    CGPoint(
      x: x.alignedToPixel(forScreenWithScale: scale),
      y: y.alignedToPixel(forScreenWithScale: scale))
  }

}
