//  Created by Sebastien Audeon on 11/26/20.
//  Copyright © 2020 Airbnb. All rights reserved.

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

// MARK: CalendarItemViewRepresentable

class FooterView: CalendarItemViewRepresentable {

  struct InvariantViewProperties: Hashable {
    var font = UIFont.systemFont(ofSize: 12)
    var textAlignment = NSTextAlignment.center
    var textColor: UIColor
  }

  struct ViewModel: Equatable {
    let monthText: String
  }
  
  static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> UILabel
  {
    let label = UILabel()
    label.font = invariantViewProperties.font
    label.textAlignment = invariantViewProperties.textAlignment
    label.textColor = invariantViewProperties.textColor
    return label
  }

  static func setViewModel(_ viewModel: ViewModel, on view: UILabel) {
    view.text = viewModel.monthText
  }

}
