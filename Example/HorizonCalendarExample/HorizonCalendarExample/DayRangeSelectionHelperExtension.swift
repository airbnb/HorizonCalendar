// Created by Bryan Keller on 2/8/23.
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

import HorizonCalendar
import UIKit

extension DayRangeSelectionHelper {
    
    static func updateDayRange(afterDragSelectionOf day: Day,
                               existingDayRange: inout DayComponentsRange?,
                               initialDayRange: inout DayComponentsRange?,
                               state: UIGestureRecognizer.State,
                               calendar: Calendar) -> Set<Date> {
            
        let invalidDates = getInvalidDateSet(day, existingDayRange, calendar)
        
        guard invalidDates == [] else { return invalidDates }
            
        switch state {
        case .began:
            if day != existingDayRange?.lowerBound, day != existingDayRange?.upperBound {
                existingDayRange = day...day
            }
            initialDayRange = existingDayRange
            
        case .changed, .ended:
            guard initialDayRange != nil else {
                fatalError("`initialDayRange` should not be `nil`")
            }
            
            performUpdateRange(day,
                               &existingDayRange,
                               &initialDayRange,
                               calendar)
            
        default:
            existingDayRange = nil
            initialDayRange = nil
        }
            
        
        
        return []
    }
    
}
