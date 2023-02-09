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

struct SwiftUIDayView: View {

  let dayNumber: Int
  let isSelected: Bool

  var body: some View {
    ZStack(alignment: .center) {
      Circle()
        .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 2)
        .background {
          Circle()
            .foregroundColor(isSelected ? Color(UIColor.systemBackground) : .clear)
        }
        .aspectRatio(1, contentMode: .fill)
      Text("\(dayNumber)").foregroundColor(Color(UIColor.label))
    }
  }

}

struct SwiftUIDayView_Previews: PreviewProvider {

  // MARK: Internal

  static var previews: some View {
    Group {
      SwiftUIDayView(dayNumber: 1, isSelected: false)
      SwiftUIDayView(dayNumber: 19, isSelected: false)
      SwiftUIDayView(dayNumber: 27, isSelected: true)
    }
    .frame(width: 50, height: 50)
  }

  // MARK: Private

  private static let calendar = Calendar.current
}
