// Created by Bryan Keller on 2/2/23.
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

import CoreGraphics

/// The layout context for a day range, containing information about the frames of days in the day range and the bounding rect (union)
/// of those frames. This can be used in a custom day range view to draw the day range in the correct location.
public struct DayRangeLayoutContext: Hashable {
  /// The day range that this layout context describes.
  public let dayRange: DayRange

  /// An ordered list of tuples containing day and day frame pairs.
  ///
  /// Each frame represents the frame of an individual day in the day range in the coordinate system of
  /// `boundingUnionRectOfDayFrames`. If a day range extends beyond the `visibleDateRange`, this array will only
  /// contain the day-frame pairs for the visible portion of the day range.
  public let daysAndFrames: [(day: Day, frame: CGRect)]

  /// A rectangle that perfectly contains all day frames in `daysAndFrames`. In other words, it is the union of all day frames in
  /// `daysAndFrames`.
  public let boundingUnionRectOfDayFrames: CGRect

  public static func == (lhs: DayRangeLayoutContext, rhs: DayRangeLayoutContext) -> Bool {
    return lhs.dayRange == rhs.dayRange &&
      lhs.daysAndFrames.elementsEqual(
        rhs.daysAndFrames,
        by: { $0.day == $1.day && $0.frame == $0.frame }) &&
      lhs.boundingUnionRectOfDayFrames == rhs.boundingUnionRectOfDayFrames
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(dayRange)
    for (day, frame) in daysAndFrames {
      hasher.combine(day)
      hasher.combine(frame)
    }
    hasher.combine(boundingUnionRectOfDayFrames)
  }

}
