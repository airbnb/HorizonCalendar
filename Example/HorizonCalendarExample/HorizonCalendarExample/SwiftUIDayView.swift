// Created by Bryan Keller on 8/23/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.

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
import SwiftUI

// MARK: - SwiftUIDayView

struct SwiftUIDayView: View {

    let dayNumber: Int
    let isSelected: Bool
    let isEnabled: Bool

    // MARK: - Lifecycle
    init(day: Day, isSelected: Bool) {
        self.dayNumber = day.day
        self.isSelected = isSelected
        self.isEnabled = day.isEnabled
    }

    /// Backwards compatible
    init(dayNumber: Int, isSelected: Bool, isEnabled: Bool = true) {
        self.dayNumber = dayNumber
        self.isSelected = isSelected
        self.isEnabled = isEnabled
    }

    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
                .background {
                    if isEnabled {
                        Circle()
                            .foregroundColor(isSelected ? Color(UIColor.systemBackground) : .clear)
                    } else {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.secondary)
                            .opacity(0.3)
                            .padding(6)
                    }
                }
                .aspectRatio(1, contentMode: .fill)
            Text("\(dayNumber)").foregroundColor(isEnabled ? Color(UIColor.label) : Color(UIColor.lightText))
        }
        .accessibilityAddTraits(.isButton)
    }

}

// MARK: - SwiftUIDayView_Previews

struct SwiftUIDayView_Previews: PreviewProvider {

  // MARK: Internal

  static var previews: some View {
    Group {
        SwiftUIDayView(dayNumber: 1, isSelected: false, isEnabled: true)
        SwiftUIDayView(dayNumber: 19, isSelected: false, isEnabled: false)
        SwiftUIDayView(dayNumber: 27, isSelected: true, isEnabled: true)
    }
    .frame(width: 50, height: 50)
  }

  // MARK: Private

  private static let calendar = Calendar.current
}
