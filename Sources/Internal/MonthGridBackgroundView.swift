// Created by Bryan Keller on 4/13/22.
// Copyright © 2022 Airbnb Inc. All rights reserved.
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

// MARK: - MonthGridBackgroundView

final class MonthGridBackgroundView: UIView {

  // MARK: Lifecycle

  fileprivate init(invariantViewProperties: InvariantViewProperties) {
    self.invariantViewProperties = invariantViewProperties
    super.init(frame: .zero)
    backgroundColor = .clear
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    context?.setLineWidth(invariantViewProperties.lineWidth)
    context?.setStrokeColor(invariantViewProperties.color.cgColor)

    if traitCollection.layoutDirection == .rightToLeft {
      transform = .init(scaleX: -1, y: 1)
    } else {
      transform = .identity
    }

    for dayFrame in framesOfDays {
      let gridRect = CGRect(
        x: dayFrame.minX - (invariantViewProperties.horizontalDayMargin / 2),
        y: dayFrame.minY - (invariantViewProperties.verticalDayMargin / 2),
        width: dayFrame.width + invariantViewProperties.horizontalDayMargin,
        height: dayFrame.height + invariantViewProperties.verticalDayMargin)
      context?.stroke(gridRect)
    }
  }

  // MARK: Fileprivate

  fileprivate var framesOfDays = Set<CGRect>() {
    didSet {
      guard framesOfDays != oldValue else { return }
      setNeedsDisplay()
    }
  }

  // MARK: Private

  private let invariantViewProperties: InvariantViewProperties

}

// MARK: CalendarItemViewRepresentable

extension MonthGridBackgroundView: CalendarItemViewRepresentable {

  struct InvariantViewProperties: Hashable {
    var lineWidth: CGFloat = 1
    var color = UIColor(red: 235/255, green: 235/255, blue: 235/255, alpha: 1)
    var horizontalDayMargin: CGFloat
    var verticalDayMargin: CGFloat
  }

  struct ViewModel: Equatable {
    let framesOfDays: Set<CGRect>
  }

  static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> MonthGridBackgroundView
  {
    MonthGridBackgroundView(invariantViewProperties: invariantViewProperties)
  }

  static func setViewModel(_ viewModel: ViewModel, on view: MonthGridBackgroundView) {
    view.framesOfDays = viewModel.framesOfDays
  }

}

// MARK: CGRect + Hashable

extension CGRect: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(origin.x)
    hasher.combine(origin.y)
    hasher.combine(size.width)
    hasher.combine(size.height)
  }

}
