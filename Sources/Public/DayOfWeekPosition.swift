// Created by Bryan Keller on 5/31/20.
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

import Foundation

// MARK: - DayOfWeekPosition

/// Represents a day of the week. In the Gregorian calendar, the first position is Sunday and the last position is Saturday. All calendars
/// in `Foundation.Calendar` have 7 day of the week positions.
public enum DayOfWeekPosition: Int, CaseIterable, Equatable {

  // MARK: Public

  case first = 1
  case second
  case third
  case fourth
  case fifth
  case sixth
  case last

  // MARK: Internal

  static let numberOfPositions = 7

}

// MARK: Comparable

extension DayOfWeekPosition: Comparable {

  public static func < (lhs: DayOfWeekPosition, rhs: DayOfWeekPosition) -> Bool {
    lhs.rawValue < rhs.rawValue
  }

}
