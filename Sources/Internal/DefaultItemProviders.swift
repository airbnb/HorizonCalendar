// Created by Bryan Keller on 7/15/20.
// Copyright © 2020 Airbnb Inc. All rights reserved.
//
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

// MARK: - DefaultLabel

struct DefaultLabelRepresenting: CalendarItemViewRepresentable {

  struct InvariantViewProperties: Hashable {
    let font: UIFont
    let textAlignment: NSTextAlignment
    let textColor: UIColor
    let backgroundColor: UIColor
    let isAccessibilityElement: Bool
    let accessibilityTraits: UIAccessibilityTraits
  }

  struct ViewModel: Equatable {
    let text: String
    let accessibilityLabel: String?
  }

  // MARK: Internal

  static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> UILabel
  {
    let label = UILabel()
    label.font = invariantViewProperties.font
    label.textAlignment = invariantViewProperties.textAlignment
    label.textColor = invariantViewProperties.textColor
    label.backgroundColor = invariantViewProperties.backgroundColor
    label.isAccessibilityElement = invariantViewProperties.isAccessibilityElement
    label.accessibilityTraits = invariantViewProperties.accessibilityTraits
    return label
  }

  static func setViewModel(_ viewModel: ViewModel, on view: UILabel) {
    view.text = viewModel.text
    view.accessibilityLabel = viewModel.accessibilityLabel
  }

}

// MARK: Default Item Providers

extension CalendarViewContent {

  // MARK: Internal

  static func defaultMonthHeaderItemModelProvider(
    for month: Month,
    calendar: Calendar,
    dateFormatter: DateFormatter)
    -> AnyCalendarItemModel
  {
    let textColor: UIColor
    if #available(iOS 13.0, *) {
      textColor = .label
    } else {
      textColor = .black
    }

    let monthText = dateFormatter.string(from: calendar.firstDate(of: month))

    return CalendarItemModel<DefaultLabelRepresenting>(
      invariantViewProperties: .init(
        font: UIFont.systemFont(ofSize: 22),
        textAlignment: .natural,
        textColor: textColor,
        backgroundColor: .clear,
        isAccessibilityElement: true,
        accessibilityTraits: [.header]),
      viewModel: .init(text: monthText, accessibilityLabel: monthText))
  }

  static func defaultDayOfWeekItemModelProvider(
    forWeekdayIndex weekdayIndex: Int,
    calendar: Calendar,
    dateFormatter: DateFormatter)
    -> AnyCalendarItemModel
  {
    let textColor: UIColor
    if #available(iOS 13.0, *) {
      textColor = .secondaryLabel
    } else {
      textColor = .black
    }

    let dayOfWeekText = dateFormatter.veryShortStandaloneWeekdaySymbols[weekdayIndex]

    return CalendarItemModel<DefaultLabelRepresenting>(
      invariantViewProperties: .init(
        font: UIFont.systemFont(ofSize: 16),
        textAlignment: .center,
        textColor: textColor,
        backgroundColor: .clear,
        isAccessibilityElement: false,
        accessibilityTraits: []),
      viewModel: .init(text: dayOfWeekText, accessibilityLabel: nil))
  }

  static func defaultDayItemModelProvider(
    for day: Day,
    calendar: Calendar,
    dateFormatter: DateFormatter)
    -> AnyCalendarItemModel
  {
    let textColor: UIColor
    if #available(iOS 13.0, *) {
      textColor = .label
    } else {
      textColor = .black
    }

    let dayText = "\(day.day)"

    let date = calendar.startDate(of: day)
    let accessibilityLabel = dateFormatter.string(from: date)

    return CalendarItemModel<DefaultLabelRepresenting>(
      invariantViewProperties: .init(
        font: UIFont.systemFont(ofSize: 18),
        textAlignment: .center,
        textColor: textColor,
        backgroundColor: .clear,
        isAccessibilityElement: true,
        accessibilityTraits: []),
      viewModel: .init(text: dayText, accessibilityLabel: accessibilityLabel))
  }

}
