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

/// The layout context for all of the views contained in a month, including frames for days, the month header, and days-of-the-week
/// headers. Also included is the bounding rect (union) of those frames. This can be used in a custom month background view to draw
/// the background around the month's foreground views.
public struct MonthLayoutContext: Hashable {

  /// The month that this layout context describes.
  public let month: Month

  /// The frame of the month header in the coordinate system of `bounds`.
  public let monthHeaderFrame: CGRect

  /// An ordered list of tuples containing day-of-the-week positions and frames.
  ///
  /// Each frame corresponds to an individual day-of-the-week item (Sunday, Monday, etc.) in the month, in the coordinate system of
  /// `bounds`. If `monthsLayout` is `.vertical`, and `pinDaysOfWeekToTop` is `true`, then this array will be empty
  /// since day-of-the-week items appear outside of individual months.
  public let dayOfWeekPositionsAndFrames: [(dayOfWeekPosition: DayOfWeekPosition, frame: CGRect)]

  /// An ordered list of tuples containing day and day frame pairs.
  ///
  /// Each frame represents the frame of an individual day in the month in the coordinate system of `bounds`.
  public let daysAndFrames: [(day: Day, frame: CGRect)]

  /// The bounds into which a background can be drawn without getting clipped. Additionally, all other frames in this type are in the
  /// coordinate system of this.
  public let bounds: CGRect

  public static func == (lhs: MonthLayoutContext, rhs: MonthLayoutContext) -> Bool {
    return lhs.month == rhs.month &&
      lhs.monthHeaderFrame == rhs.monthHeaderFrame &&
      lhs.dayOfWeekPositionsAndFrames.elementsEqual(
        rhs.dayOfWeekPositionsAndFrames,
        by: { $0.dayOfWeekPosition == $1.dayOfWeekPosition && $0.frame == $1.frame }) &&
      lhs.daysAndFrames.elementsEqual(
        rhs.daysAndFrames,
        by: { $0.day == $1.day && $0.frame == $0.frame }) &&
      lhs.bounds == rhs.bounds
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(month)
    hasher.combine(monthHeaderFrame)
    for (dayOfWeekPosition, frame) in dayOfWeekPositionsAndFrames {
      hasher.combine(dayOfWeekPosition)
      hasher.combine(frame)
    }
    for (day, frame) in daysAndFrames {
      hasher.combine(day)
      hasher.combine(frame)
    }
    hasher.combine(bounds)
  }

}
