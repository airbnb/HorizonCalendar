// Created by Bryan Keller on 1/30/23.
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

import UIKit

// MARK: - MonthGridBackgroundView

/// A background grid view that draws separator lines between all days in a month. 
public final class MonthGridBackgroundView: UIView {

  // MARK: Lifecycle

  fileprivate init(invariantViewProperties: InvariantViewProperties) {
    self.invariantViewProperties = invariantViewProperties
    super.init(frame: .zero)
    backgroundColor = .clear
  }

  required init?(coder _: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public override func draw(_: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    context?.setLineWidth(invariantViewProperties.lineWidth)
    context?.setStrokeColor(invariantViewProperties.color.cgColor)

    if traitCollection.layoutDirection == .rightToLeft {
      context?.translateBy(x: bounds.midX, y: bounds.midY)
      context?.scaleBy(x: -1, y: 1)
      context?.translateBy(x: -bounds.midX, y: -bounds.midY)
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

  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    setNeedsDisplay()
  }

  // MARK: Fileprivate

  fileprivate var framesOfDays = [CGRect]() {
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

  public struct InvariantViewProperties: Hashable {

    // MARK: Lifecycle

    public init(
      lineWidth: CGFloat = 1,
      color: UIColor = .lightGray,
      horizontalDayMargin: CGFloat,
      verticalDayMargin: CGFloat)
    {
      self.lineWidth = lineWidth
      self.color = color
      self.horizontalDayMargin = horizontalDayMargin
      self.verticalDayMargin = verticalDayMargin
    }

    // MARK: Internal

    var lineWidth: CGFloat
    var color: UIColor
    var horizontalDayMargin: CGFloat
    var verticalDayMargin: CGFloat
  }

  public struct Content: Equatable {

    // MARK: Lifecycle

    public init(framesOfDays: [CGRect]) {
      self.framesOfDays = framesOfDays
    }

    // MARK: Internal

    let framesOfDays: [CGRect]
  }

  public static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> MonthGridBackgroundView
  {
    MonthGridBackgroundView(invariantViewProperties: invariantViewProperties)
  }

  public static func setContent(_ content: Content, on view: MonthGridBackgroundView) {
    view.framesOfDays = content.framesOfDays
  }

}
