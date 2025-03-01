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

typealias Day = DayComponents
/// Represents the day, including availability. Backwards compatible with prior versions of Day aliasing to DayComponents.
public struct Day: Hashable {
    
    // MARK: - Public
    public let components: DayComponents
    public var day: DayComponents {
        return components
    }
    public var isEnabled: Bool
    
    init(month: MonthComponents, day: Int, isEnabled: Bool = true) {
        self.components = DayComponents(month: month, day: day)
        self.isEnabled = isEnabled
    }
 }
