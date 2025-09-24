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

// MARK: - Day

public protocol DayAvailabilityProvider {
    func isEnabled(_ day: DayComponents) -> Bool
    func isEnabled(_ day: Date) -> Bool
}

public protocol DayProtcol: Hashable, Comparable {
    static var availabilityProvider: DayAvailabilityProvider? { get set }

    var components: DateComponents { get }

    var month: MonthComponents { get }

    var day: Int { get }

    var isEnabled: Bool { get }
}

/// Represents the day, including availability. Backwards compatible with prior versions of Day aliasing to
/// DayComponents.
public struct Day: DayProtcol {
    // MARK: - Private

    private let _dayComponents: DayComponents

    // MARK: - Public

    // Reference to the availability provider
    public static var availabilityProvider: DayAvailabilityProvider?

    /// Forwarding to support existing codebase
    public var components: DateComponents {
        _dayComponents.components
    }

    public var month: MonthComponents {
        _dayComponents.month
    }

    public var day: Int {
        _dayComponents.day
    }

    public var isEnabled: Bool

    init(month: MonthComponents, day: Int) {
        _dayComponents = DayComponents(month: month, day: day)
        isEnabled = Day.availabilityProvider?.isEnabled(_dayComponents) ?? true
    }
}

// Implement Comparable
public extension Day {
    static func < (lhs: Day, rhs: Day) -> Bool {
        lhs._dayComponents < rhs._dayComponents
    }

    static func > (lhs: Day, rhs: Day) -> Bool {
        lhs._dayComponents > rhs._dayComponents
    }

    static func == (lhs: Day, rhs: Day) -> Bool {
        lhs._dayComponents == rhs._dayComponents
    }

    static func >= (lhs: Day, rhs: Day) -> Bool {
        lhs == rhs || lhs > rhs
    }

    static func <= (lhs: Day, rhs: Day) -> Bool {
        lhs == rhs || lhs < rhs
    }
}

/// Explicitly implement Hashable
public extension Day {
    func hash(into hasher: inout Hasher) {
        hasher.combine(day)
        hasher.combine(month)
        hasher.combine(isEnabled)
        hasher.combine(components)
    }
}
