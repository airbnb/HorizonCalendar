// Created by Bryan Keller on 4/15/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

import UIKit

/// A `CALayer` subclass that enables an observer to be notified when `render(in:)` is called (usually for the purpose of
/// doing some work before a layer is snapshotted). This is needed so that `CalendarView` can sort its
/// `scrollView.sublayers` array before snapshotting, since `render(in:)` does not respect `CALayer` `zPosition`
///  values.
final class RenderInContextObservingLayer: CALayer {

  var willRenderInContext: (() -> Void)?

  override func render(in ctx: CGContext) {
    willRenderInContext?()
    super.render(in: ctx)
  }

}
