// Created by Bryan Keller on 1/15/20.
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

import UIKit

// MARK: - CalendarView

/// A declarative, performant calendar `UIView` that supports use cases ranging from simple date pickers all the way up to
/// fully-featured calendar apps. Its declarative API makes updating the calendar straightforward, while also providing many
/// customization points to support a diverse set of designs and use cases.
///
/// `CalendarView` does not handle any business logic related to day range selection or deselection. Instead, it provides a
/// single callback for day selection, allowing you to customize selection behavior in any way that you’d like.
///
/// Your business logic can respond to the day selection callback, regenerate `CalendarView` content based on changes to the
/// backing-models for your feature, then set the content on `CalendarView`. This will trigger `CalendarView` to re-render,
/// reflecting all new changes from the content you provide.
///
/// `CalendarView`’s content contains all information about how to render the calendar (you can think of `CalendarView` as a
/// pure function of its content). The most important things provided by the content are:
/// * The date range to display
///   * e.g. September, 2019 - April, 2020
/// * A months-layout (vertical or horizontal)
/// * An optional `CalendarItem` to display for each day in the date range if you don't want to use the default day view
///   * e.g. a view with a label representing a single day
public final class CalendarView: UIView {

  // MARK: Lifecycle

  /// Initializes a new `CalendarView` instance with the provided initial content.
  ///
  /// - Parameters:
  ///   - initialContent: The content to use when initially rendering `CalendarView`.
  public init(initialContent: CalendarViewContent) {
    content = initialContent
    super.init(frame: .zero)
    commonInit()
  }

  required init?(coder: NSCoder) {
    let startDate = Date() // now
    let endDate = Date(timeIntervalSinceNow: 31_536_000) // one year from now
    content = CalendarViewContent(visibleDateRange: startDate...endDate, monthsLayout: .vertical)
    super.init(coder: coder)
    commonInit()
  }

  // MARK: Public

  /// A closure (that is retained) that is invoked whenever a day is selected. It is the responsibility of your feature code to decide what to
  /// do with each day. For example, you might store the most recent day in a selected day property, then read that property in your
  /// `dayItemProvider` closure to add specific "selected" styling to a particular day view.
  public var daySelectionHandler: ((DayComponents) -> Void)?

  /// A closure (that is retained) that is invoked inside `scrollViewDidScroll(_:)`
  public var didScroll: ((_ visibleDayRange: DayComponentsRange, _ isUserDragging: Bool) -> Void)?

  /// A closure (that is retained) that is invoked inside `scrollViewDidEndDragging(_: willDecelerate:)`.
  public var didEndDragging: ((_ visibleDayRange: DayComponentsRange, _ willDecelerate: Bool) -> Void)?

  /// A closure (that is retained) that is invoked inside `scrollViewDidEndDecelerating(_:)`.
  public var didEndDecelerating: ((_ visibleDayRange: DayComponentsRange) -> Void)?

  /// A closure (that is retained) that is invoked during a multiple-selection-drag-gesture. Multiple selection is initiated with a long press,
  /// followed by a drag / pan. As the gesture crosses over more days in the calendar, this handler will be invoked with each new day. It
  /// is the responsibility of your feature code to decide what to do with this stream of days. For example, you might convert them to
  /// `Date` instances and use them as input to the `dayRangeItemProvider`.
  public var multiDaySelectionDragHandler: ((DayComponents, UIGestureRecognizer.State) -> Void)? {
    didSet {
      configureMultiDaySelectionPanGestureRecognizer()
    }
  }

  /// Whether or not the calendar's scroll view is currently over-scrolling, i.e, whether the rubber-banding or bouncing effect is in
  /// progress.
  public var isOverScrolling: Bool {
    let scrollAxis = scrollMetricsMutator.scrollAxis
    let offset = scrollView.offset(for: scrollAxis)

    return offset < scrollView.minimumOffset(for: scrollAxis) ||
      offset > scrollView.maximumOffset(for: scrollAxis)
  }

  /// The range of months that are partially of fully visible.
  public var visibleMonthRange: MonthComponentsRange? {
    visibleItemsDetails?.visibleMonthRange
  }

  /// The range of days that are partially or fully visible.
  public var visibleDayRange: DayComponentsRange? {
    visibleItemsDetails?.visibleDayRange
  }

  /// `CalendarView` only supports positive values for `layoutMargins`. Negative values will be changed to `0`.
  public override var layoutMargins: UIEdgeInsets {
    get { super.layoutMargins }
    set {
      super.layoutMargins = UIEdgeInsets(
        top: max(newValue.top, 0),
        left: max(newValue.left, 0),
        bottom: max(newValue.bottom, 0),
        right: max(newValue.right, 0))
    }
  }

  /// `CalendarView` only supports positive values for `directionalLayoutMargins`. Negative values will be changed to
  /// `0`.
  public override var directionalLayoutMargins: NSDirectionalEdgeInsets {
    get { super.directionalLayoutMargins }
    set {
      super.directionalLayoutMargins = NSDirectionalEdgeInsets(
        top: max(newValue.top, 0),
        leading: max(newValue.leading, 0),
        bottom: max(newValue.bottom, 0),
        trailing: max(newValue.trailing, 0))
    }
  }

  public override func didMoveToWindow() {
    super.didMoveToWindow()

    if window == nil {
      scrollToItemContext = nil
    }
  }

  public override func layoutMarginsDidChange() {
    super.layoutMarginsDidChange()
    setNeedsLayout()
  }

  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)

    // This can be called with a different trait collection instance, even if nothing in the trait
    // collection has changed (noticed from SwiftUI). We guard against this to prevent and
    // unnecessary layout pass.
    guard traitCollection.layoutDirection != previousTraitCollection?.layoutDirection else {
      return
    }
    setNeedsLayout()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    // Setting the scroll view's frame in `layoutSubviews` causes over-scrolling to not work. We
    // work around this by only setting the frame if it's changed.
    if scrollView.frame != bounds {
      scrollView.frame = bounds
    }

    if traitCollection.layoutDirection == .rightToLeft {
      scrollView.transform = .init(scaleX: -1, y: 1)
    } else {
      scrollView.transform = .identity
    }

    if bounds != previousBounds || layoutMargins != previousLayoutMargins {
      maintainScrollPositionAfterBoundsOrMarginsChange()
      previousBounds = bounds
      previousLayoutMargins = layoutMargins
    }

    guard isReadyForLayout else { return }

    // Layout with an extended bounds if Voice Over is running, reducing the likelihood of a
    // Voice Over user experiencing "No heading found" when navigating by heading. We also check to
    // make sure an accessibility element has already been focused, otherwise the first
    // accessibility element will be off-screen when a user first focuses into the calendar view.
    let extendLayoutRegion = UIAccessibility.isVoiceOverRunning && initialItemViewWasFocused

    _layoutSubviews(extendLayoutRegion: extendLayoutRegion)
  }

  /// Sets the content of the `CalendarView`, causing it to re-render, with no animation.
  ///
  /// - Parameters:
  ///   - content: The content to use when rendering `CalendarView`.
  public func setContent(_ content: CalendarViewContent) {
    setContent(content, animated: false)
  }

  /// Sets the content of the `CalendarView`, causing it to re-render, with an optional animation.
  ///
  /// If you call this function with `animated` set to `true` in your own animation closure, that animation will be used to perform
  /// the content update. If you call this function with `animated` set to `true` outside of an animation closure, a default animation
  /// will be used. Calling this function with `animated` set to `false` will result in a non-animated content update, even if you call
  /// it from an animation closure.
  ///
  /// - Parameters:
  ///   - content: The content to use when rendering `CalendarView`.
  ///   - animated: Whether or not the content update should be animated.
  public func setContent(_ content: CalendarViewContent, animated: Bool) {
    let oldContent = self.content

    let isInAnimationClosure = UIView.areAnimationsEnabled && UIView.inheritedAnimationDuration > 0

    // Do a preparation layout pass with an extended bounds, if we're animating. This ensures that
    // views don't pop in if they're animating in from outside the actual bounds.
    if animated {
      UIView.performWithoutAnimation {
        _layoutSubviews(extendLayoutRegion: isInAnimationClosure)
      }
    }

    _visibleItemsProvider = nil

    // We only need to clear the `scrollToItemContext` if the monthsLayout changed or the visible
    // day range changed.
    if content.monthsLayout != oldContent.monthsLayout || content.dayRange != oldContent.dayRange {
      scrollToItemContext = nil
    }

    let isAnchorLayoutItemValid: Bool
    switch anchorLayoutItem?.itemType {
    case .monthHeader(let month):
      isAnchorLayoutItemValid = content.monthRange.contains(month)
    case .dayOfWeekInMonth(_, let month):
      isAnchorLayoutItemValid = content.monthRange.contains(month)
    case .day(let day):
      isAnchorLayoutItemValid = content.dayRange.contains(day)
    case .none:
      isAnchorLayoutItemValid = false
    }

    if isAnchorLayoutItemValid {
      // If we have a valid `anchorLayoutItem`, change it to be the topmost item. Normally, the
      // `anchorLayoutItem` is the centermost item, but when our content changes, it can make the
      // transition look better if our layout reference point is at the top of the screen.
      anchorLayoutItem = visibleItemsDetails?.firstLayoutItem ?? anchorLayoutItem
    } else {
      // If the `anchorLayoutItem` is no longer valid (due to it no longer being in the visible day
      // range), set it to nil. This will force us to find a new `anchorLayoutItem`.
      anchorLayoutItem = nil
    }

    if content.monthsLayout.isPaginationEnabled {
      scrollView.decelerationRate = .fast
    } else {
      scrollView.decelerationRate = .normal
    }

    if
      oldContent.monthsLayout != content.monthsLayout ||
      oldContent.monthDayInsets != content.monthDayInsets ||
      oldContent.dayAspectRatio != content.dayAspectRatio ||
      oldContent.dayOfWeekAspectRatio != content.dayOfWeekAspectRatio ||
      oldContent.horizontalDayMargin != content.horizontalDayMargin ||
      oldContent.verticalDayMargin != content.verticalDayMargin
    {
      invalidateIntrinsicContentSize()
    }

    self.content = content
    setNeedsLayout()

    // If we're animating, force layout with the inherited animation closure or with our own default
    // animation. Forcing layout ensures that frame adjustments happen with an animation.
    if animated {
      let animations = {
        self.isAnimatedUpdatePass = true
        self.layoutIfNeeded()
        self.isAnimatedUpdatePass = false
      }
      if isInAnimationClosure {
        animations()
      } else {
        UIView.animate(withDuration: 0.3, animations: animations)
      }
    }
  }

  /// Returns the accessibility element associated with the specified visible date. If the date is not currently visible, then there will be no
  /// associated accessibility element and this function will return `nil`.
  ///
  /// Use this function to programmatically change the currently-focused date via
  /// `UIAccessibility.post(notification:argument:)`, passing the returned accessibility element as the parameter for
  /// `argument`.
  ///
  /// - Parameters:
  ///   - date: The date for which to obtain an accessibility element. If the date is not currently visible, then it will not have an
  ///   associated accessibility element.
  /// - Returns: An accessibility element associated with the specified `date`, or `nil` if one cannot be found.
  public func accessibilityElementForVisibleDate(_ date: Date) -> Any? {
    let day = calendar.day(containing: date)
    guard let visibleDayRange, visibleDayRange.contains(day) else { return nil }

    for (visibleItem, visibleView) in visibleViewsForVisibleItems {
      guard case .layoutItemType(.day(day)) = visibleItem.itemType else { continue }
      return visibleView
    }

    return nil
  }

  /// Scrolls the calendar to the specified month with the specified position.
  ///
  /// If the calendar has a non-zero frame, this function will scroll to the specified month immediately. Otherwise the scroll-to-month
  /// action will be queued and executed once the calendar has a non-zero frame. If this function is invoked multiple times before the
  /// calendar has a non-zero frame, only the most recent scroll-to-month action will be executed.
  ///
  /// - Parameters:
  ///   - dateInTargetMonth: A date in the target month to which to scroll into view.
  ///   - scrollPosition: The final position of the `CalendarView`'s scrollable region after the scroll completes.
  ///   - animated: Whether the scroll should be animated (from the current position), or whether the scroll should update the
  ///   visible region immediately with no animation.
  public func scroll(
    toMonthContaining dateInTargetMonth: Date,
    scrollPosition: CalendarViewScrollPosition,
    animated: Bool)
  {
    let month = calendar.month(containing: dateInTargetMonth)
    guard content.monthRange.contains(month) else {
      assertionFailure("""
          Attempted to scroll to month \(month), which is out of bounds of the total date range
          \(content.monthRange).
        """)
      return
    }

    // Cancel in-flight scroll
    scrollView.setContentOffset(scrollView.contentOffset, animated: false)

    scrollToItemContext = ScrollToItemContext(
      targetItem: .month(month),
      scrollPosition: scrollPosition,
      animated: animated)

    if animated {
      startScrollingTowardTargetItem()
    } else {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  /// Scrolls the calendar to the specified day with the specified position.
  ///
  /// If the calendar has a non-zero frame, this function will scroll to the specified day immediately. Otherwise the scroll-to-day action
  /// will be queued and executed once the calendar has a non-zero frame. If this function is invoked multiple times before the calendar
  /// has a non-zero frame, only the most recent scroll-to-day action will be executed.
  ///
  /// - Parameters:
  ///   - dateInTargetDay: A date in the target day to which to scroll into view.
  ///   - scrollPosition: The final position of the `CalendarView`'s scrollable region after the scroll completes.
  ///   - animated: Whether the scroll should be animated (from the current position), or whether the scroll should update the
  ///   visible region immediately with no animation.
  public func scroll(
    toDayContaining dateInTargetDay: Date,
    scrollPosition: CalendarViewScrollPosition,
    animated: Bool)
  {
    let day = calendar.day(containing: dateInTargetDay)
    guard content.dayRange.contains(day) else {
      assertionFailure("""
          Attempted to scroll to day \(day), which is out of bounds of the total date range
          \(content.dayRange).
        """)
      return
    }

    // Cancel in-flight scroll
    scrollView.setContentOffset(scrollView.contentOffset, animated: false)

    scrollToItemContext = ScrollToItemContext(
      targetItem: .day(day),
      scrollPosition: scrollPosition,
      animated: animated)

    if animated {
      startScrollingTowardTargetItem()
    } else {
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  // MARK: Internal

  lazy var doubleLayoutPassSizingLabel = DoubleLayoutPassSizingLabel(provider: self)

  // MARK: Fileprivate

  fileprivate var content: CalendarViewContent

  fileprivate var previousPageIndex: Int?

  fileprivate lazy var scrollView: CalendarScrollView = {
    let scrollView = CalendarScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = scrollViewDelegate
    return scrollView
  }()

  fileprivate lazy var multiDaySelectionLongPressGestureRecognizer: UILongPressGestureRecognizer = {
    let gestureRecognizer = UILongPressGestureRecognizer(
      target: self,
      action: #selector(multiDaySelectionGestureRecognized(_:)))
    gestureRecognizer.allowableMovement = .greatestFiniteMagnitude
    gestureRecognizer.delegate = gestureRecognizerDelegate
    return gestureRecognizer
  }()

  fileprivate lazy var multiDaySelectionPanGestureRecognizer: UIPanGestureRecognizer = {
    let gestureRecognizer = UIPanGestureRecognizer(
      target: self,
      action: #selector(multiDaySelectionGestureRecognized(_:)))
    gestureRecognizer.maximumNumberOfTouches = 1
    gestureRecognizer.maximumNumberOfTouches = 1
    gestureRecognizer.delegate = gestureRecognizerDelegate
    return gestureRecognizer
  }()

  fileprivate var scrollToItemContext: ScrollToItemContext? {
    willSet {
      scrollToItemDisplayLink?.invalidate()
    }
  }

  fileprivate var calendar: Calendar {
    content.calendar
  }

  // This hack is needed to prevent the scroll view from over-scrolling far past the content. This
  // occurs in 2 scenarios:
  // - On macOS if you scroll quickly toward a boundary
  // - On iOS if you scroll quickly toward a boundary and targetContentOffset is mutated
  //
  // https://openradar.appspot.com/radar?id=4966130615582720 demonstrates this issue on macOS.
  fileprivate func preventLargeOverScrollIfNeeded() {
    guard isRunningOnMac || content.monthsLayout.isPaginationEnabled else { return }

    let scrollAxis = scrollMetricsMutator.scrollAxis
    let offset = scrollView.offset(for: scrollAxis)

    let boundsSize: CGFloat
    switch scrollAxis {
    case .vertical: boundsSize = scrollView.bounds.height * 0.7
    case .horizontal: boundsSize = scrollView.bounds.width * 0.7
    }

    let newOffset: CGPoint?
    if offset < scrollView.minimumOffset(for: scrollAxis) - boundsSize {
      switch scrollAxis {
      case .vertical:
        newOffset = CGPoint(
          x: scrollView.contentOffset.x,
          y: scrollView.minimumOffset(for: scrollAxis))

      case .horizontal:
        newOffset = CGPoint(
          x: scrollView.minimumOffset(for: scrollAxis),
          y: scrollView.contentOffset.y)
      }
    } else if offset > scrollView.maximumOffset(for: scrollAxis) + boundsSize {
      switch scrollAxis {
      case .vertical:
        newOffset = CGPoint(
          x: scrollView.contentOffset.x,
          y: scrollView.maximumOffset(for: scrollAxis))

      case .horizontal:
        newOffset = CGPoint(
          x: scrollView.maximumOffset(for: scrollAxis),
          y: scrollView.contentOffset.y)
      }
    } else {
      newOffset = nil
    }

    if let newOffset {
      scrollView.performWithoutNotifyingDelegate {
        // Passing `false` for `animated` is necessary to stop the in-flight deceleration animation
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
          self.scrollView.setContentOffset(newOffset, animated: false)
        })
      }
    }
  }

  // MARK: Private

  private let reuseManager = ItemViewReuseManager()
  private let subviewInsertionIndexTracker = SubviewInsertionIndexTracker()

  private var _scrollMetricsMutator: ScrollMetricsMutator?

  private var anchorLayoutItem: LayoutItem?
  private var _visibleItemsProvider: VisibleItemsProvider?
  private var visibleItemsDetails: VisibleItemsDetails?
  private var visibleViewsForVisibleItems = [VisibleItem: ItemView]()

  private var isAnimatedUpdatePass = false

  private var previousBounds = CGRect.zero
  private var previousLayoutMargins = UIEdgeInsets.zero

  private weak var scrollToItemDisplayLink: CADisplayLink?
  private var scrollToItemAnimationStartTime: CFTimeInterval?

  private weak var autoScrollDisplayLink: CADisplayLink?
  private var autoScrollOffset: CGFloat?

  private var lastMultiDaySelectionDay: Day?

  private lazy var scrollViewDelegate = ScrollViewDelegate(calendarView: self)
  private lazy var gestureRecognizerDelegate = GestureRecognizerDelegate(calendarView: self)

  // Necessary to work around a `UIScrollView` behavior difference on Mac. See `scrollViewDidScroll`
  // and `preventLargeOverScrollIfNeeded` for more context.
  private lazy var isRunningOnMac: Bool = {
    if #available(iOS 13.0, *) {
      if ProcessInfo.processInfo.isMacCatalystApp {
        return true
      }
    }

    return false
  }()

  private var initialItemViewWasFocused = false {
    didSet {
      guard initialItemViewWasFocused != oldValue else { return }
      setNeedsLayout()
      layoutIfNeeded()
    }
  }

  private var isReadyForLayout: Bool {
    // There's no reason to attempt layout unless we have a non-zero `bounds.size`. We'll have a
    // non-zero size once the `frame` is set to something non-zero, either manually or via the
    // Auto Layout engine.
    bounds.size != .zero
  }

  private var scale: CGFloat {
    let scale = traitCollection.displayScale
    // The documentation mentions that 0 is a possible value, so we guard against this.
    // It's unclear whether values between 0 and 1 are possible, otherwise `max(scale, 1)` would
    // suffice.
    return scale > 0 ? scale : 1
  }

  private var scrollMetricsMutator: ScrollMetricsMutator {
    let scrollAxis: ScrollAxis
    switch content.monthsLayout {
    case .vertical: scrollAxis = .vertical
    case .horizontal: scrollAxis = .horizontal
    }

    let scrollMetricsMutator: ScrollMetricsMutator
    if let previousScrollMetricsMutator = _scrollMetricsMutator {
      if scrollAxis != previousScrollMetricsMutator.scrollAxis {
        scrollMetricsMutator = ScrollMetricsMutator(
          scrollMetricsProvider: scrollView,
          scrollAxis: scrollAxis)
      } else {
        scrollMetricsMutator = previousScrollMetricsMutator
      }
    } else {
      scrollMetricsMutator = ScrollMetricsMutator(
        scrollMetricsProvider: scrollView,
        scrollAxis: scrollAxis)
    }

    _scrollMetricsMutator = scrollMetricsMutator

    return scrollMetricsMutator
  }

  private var visibleItemsProvider: VisibleItemsProvider {
    if
      let existingVisibleItemsProvider = _visibleItemsProvider,
      existingVisibleItemsProvider.size == bounds.size,
      existingVisibleItemsProvider.layoutMargins == directionalLayoutMargins,
      existingVisibleItemsProvider.scale == scale,
      existingVisibleItemsProvider.backgroundColor == backgroundColor
    {
      return existingVisibleItemsProvider
    } else {
      let visibleItemsProvider = VisibleItemsProvider(
        calendar: calendar,
        content: content,
        size: bounds.size,
        layoutMargins: directionalLayoutMargins,
        scale: scale,
        backgroundColor: backgroundColor)
      _visibleItemsProvider = visibleItemsProvider
      return visibleItemsProvider
    }
  }

  private var maximumPerAnimationTickOffset: CGFloat {
    switch content.monthsLayout {
    case .vertical: return bounds.height
    case .horizontal: return bounds.width
    }
  }

  private var firstLayoutMarginValue: CGFloat {
    switch content.monthsLayout {
    case .vertical: return directionalLayoutMargins.top
    case .horizontal: return directionalLayoutMargins.leading
    }
  }

  private var lastLayoutMarginValue: CGFloat {
    switch content.monthsLayout {
    case .vertical: return directionalLayoutMargins.bottom
    case .horizontal: return directionalLayoutMargins.trailing
    }
  }

  private func commonInit() {
    if #available(iOS 13.0, *) {
      backgroundColor = .systemBackground
    } else {
      backgroundColor = .white
    }

    // Must be the first subview so that `UINavigationController` can monitor its scroll position
    // and make navigation bars opaque on scroll.
    insertSubview(scrollView, at: 0)

    installDoubleLayoutPassSizingLabel()

    setContent(content)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(accessibilityElementFocused(_:)),
      name: UIAccessibility.elementFocusedNotification,
      object: nil)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(setNeedsLayout),
      name: UIAccessibility.voiceOverStatusDidChangeNotification,
      object: nil)
  }

  private func anchorLayoutItem(
    for scrollToItemContext: ScrollToItemContext,
    visibleItemsProvider: VisibleItemsProvider)
    -> LayoutItem
  {
    let offset: CGPoint
    switch scrollMetricsMutator.scrollAxis {
    case .vertical:
      offset = CGPoint(
        x: scrollView.contentOffset.x + directionalLayoutMargins.leading,
        y: scrollView.contentOffset.y)
    case .horizontal:
      offset = CGPoint(
        x: scrollView.contentOffset.x,
        y: scrollView.contentOffset.y + directionalLayoutMargins.top)
    }

    switch scrollToItemContext.targetItem {
    case .month(let month):
      return visibleItemsProvider.anchorMonthHeaderItem(
        for: month,
        offset: offset,
        scrollPosition: scrollToItemContext.scrollPosition)
    case .day(let day):
      return visibleItemsProvider.anchorDayItem(
        for: day,
        offset: offset,
        scrollPosition: scrollToItemContext.scrollPosition)
    }
  }

  private func positionRelativeToVisibleBounds(
    for targetItem: ScrollToItemContext.TargetItem)
    -> ScrollToItemContext.PositionRelativeToVisibleBounds?
  {
    guard let visibleItemsDetails else { return nil }

    switch targetItem {
    case .month(let month):
      let monthHeaderItemType = LayoutItem.ItemType.monthHeader(month)
      if let monthFrame = visibleItemsDetails.framesForVisibleMonths[month] {
        return .partiallyOrFullyVisible(frame: monthFrame)
      } else if monthHeaderItemType < visibleItemsDetails.centermostLayoutItem.itemType {
        return .before
      } else if monthHeaderItemType > visibleItemsDetails.centermostLayoutItem.itemType {
        return .after
      } else {
        preconditionFailure("Could not find a corresponding frame for \(month).")
      }

    case .day(let day):
      let dayLayoutItemType = LayoutItem.ItemType.day(day)
      if let dayFrame = visibleItemsDetails.framesForVisibleDays[day] {
        return .partiallyOrFullyVisible(frame: dayFrame)
      } else if dayLayoutItemType < visibleItemsDetails.centermostLayoutItem.itemType {
        return .before
      } else if dayLayoutItemType > visibleItemsDetails.centermostLayoutItem.itemType {
        return .after
      } else {
        preconditionFailure("Could not find a corresponding frame for \(day).")
      }
    }
  }

  // This exists so that we can force a layout ourselves in preparation for an animated update.
  private func _layoutSubviews(extendLayoutRegion: Bool) {
    scrollView.performWithoutNotifyingDelegate {
      scrollMetricsMutator.setUpInitialMetricsIfNeeded()
      scrollMetricsMutator.updateContentSizePerpendicularToScrollAxis(viewportSize: bounds.size)
    }

    let anchorLayoutItem: LayoutItem
    if let scrollToItemContext, !scrollToItemContext.animated {
      anchorLayoutItem = self.anchorLayoutItem(
        for: scrollToItemContext,
        visibleItemsProvider: visibleItemsProvider)
      // Clear the `scrollToItemContext` once we use it. This could happen over the course of
      // several layout pass attempts since `isReadyForLayout` might be false initially.
      self.scrollToItemContext = nil
    } else if let previousAnchorLayoutItem = self.anchorLayoutItem {
      anchorLayoutItem = previousAnchorLayoutItem
    } else {
      let initialScrollToItemContext = ScrollToItemContext(
        targetItem: .month(content.monthRange.lowerBound),
        scrollPosition: .firstFullyVisiblePosition,
        animated: false)
      anchorLayoutItem = self.anchorLayoutItem(
        for: initialScrollToItemContext,
        visibleItemsProvider: visibleItemsProvider)
    }

    let currentVisibleItemsDetails = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: anchorLayoutItem,
      offset: scrollView.contentOffset,
      extendLayoutRegion: extendLayoutRegion)
    self.anchorLayoutItem = currentVisibleItemsDetails.centermostLayoutItem

    updateVisibleViews(withVisibleItems: currentVisibleItemsDetails.visibleItems)

    visibleItemsDetails = currentVisibleItemsDetails

    let minimumScrollOffset = visibleItemsDetails?.contentStartBoundary.map {
      ($0 - firstLayoutMarginValue).alignedToPixel(forScreenWithScale: scale)
    }
    let maximumScrollOffset = visibleItemsDetails?.contentEndBoundary.map {
      ($0 + lastLayoutMarginValue).alignedToPixel(forScreenWithScale: scale)
    }
    scrollView.performWithoutNotifyingDelegate {
      scrollMetricsMutator.updateScrollBoundaries(
        minimumScrollOffset: minimumScrollOffset,
        maximumScrollOffset: maximumScrollOffset)
    }

    scrollView.cachedAccessibilityElements = nil
  }

  private func updateVisibleViews(withVisibleItems visibleItems: Set<VisibleItem>) {
    var viewsToHideForVisibleItems = visibleViewsForVisibleItems
    visibleViewsForVisibleItems.removeAll(keepingCapacity: true)

    let contexts = reuseManager.reusedViewContexts(
      visibleItems: visibleItems,
      reuseUnusedViews: !UIAccessibility.isVoiceOverRunning)

    for context in contexts {
      UIView.conditionallyPerformWithoutAnimation(when: !context.isReusedViewSameAsPreviousView) {
        if context.view.superview == nil {
          let insertionIndex = subviewInsertionIndexTracker.insertionIndex(
            forSubviewWithCorrespondingItemType: context.visibleItem.itemType)
          scrollView.insertSubview(context.view, at: insertionIndex)
        }

        context.view.isHidden = false

        configureView(context.view, with: context.visibleItem)
      }

      visibleViewsForVisibleItems[context.visibleItem] = context.view

      if context.isViewReused {
        // Don't hide views that were reused
        viewsToHideForVisibleItems.removeValue(forKey: context.visibleItem)
      }
    }

    // Hide any old views that weren't reused. This is faster than adding / removing subviews.
    // If VoiceOver is running, we remove the view to save memory (since views aren't reused).
    for (visibleItem, viewToHide) in viewsToHideForVisibleItems {
      if UIAccessibility.isVoiceOverRunning {
        viewToHide.removeFromSuperview()
        subviewInsertionIndexTracker.removedSubview(withCorrespondingItemType: visibleItem.itemType)
      } else {
        viewToHide.isHidden = true
      }
    }
  }

  private func configureView(_ view: ItemView, with visibleItem: VisibleItem) {
    let calendarItemModel = visibleItem.calendarItemModel
    view.calendarItemModel = calendarItemModel
    view.itemType = visibleItem.itemType
    view.frame = visibleItem.frame.alignedToPixels(forScreenWithScale: scale)

    if traitCollection.layoutDirection == .rightToLeft {
      view.transform = .init(scaleX: -1, y: 1)
    } else {
      view.transform = .identity
    }

    // Set up the selection handler
    if case .layoutItemType(.day(let day)) = visibleItem.itemType {
      view.selectionHandler = { [weak self] in
        self?.daySelectionHandler?(day)
      }
    } else {
      view.selectionHandler = nil
    }
  }

  private func startScrollingTowardTargetItem() {
    let scrollToItemDisplayLink = CADisplayLink(
      target: self,
      selector: #selector(scrollToItemDisplayLinkFired))

    scrollToItemAnimationStartTime = CACurrentMediaTime()

    if #available(iOS 15.0, *) {
      #if swift(>=5.5) // Allows us to still build using Xcode 12
      scrollToItemDisplayLink.preferredFrameRateRange = CAFrameRateRange(
        minimum: 80,
        maximum: 120,
        preferred: 120)
      #endif
    }

    scrollToItemDisplayLink.add(to: .main, forMode: .common)
    self.scrollToItemDisplayLink = scrollToItemDisplayLink
  }

  private func finalizeScrollingTowardItem(for scrollToItemContext: ScrollToItemContext) {
    self.scrollToItemContext = ScrollToItemContext(
      targetItem: scrollToItemContext.targetItem,
      scrollPosition: scrollToItemContext.scrollPosition,
      animated: false)
  }

  @objc
  private func scrollToItemDisplayLinkFired() {
    guard
      let scrollToItemContext,
      let animationStartTime = scrollToItemAnimationStartTime
    else {
      preconditionFailure("""
          Expected `scrollToItemContext`, `animationStartTime`, and `scrollMetricsMutator` to be
          non-nil when animating toward an item.
        """)
    }

    guard scrollToItemContext.animated else {
      preconditionFailure(
        "The scroll-to-item animation display link fired despite no animation being needed.")
    }

    guard isReadyForLayout else { return }

    let positionBeforeLayout = positionRelativeToVisibleBounds(for: scrollToItemContext.targetItem)

    let secondsSinceAnimationStart = CACurrentMediaTime() - animationStartTime
    let offset = maximumPerAnimationTickOffset * CGFloat(min(secondsSinceAnimationStart / 5, 1))
    switch positionBeforeLayout {
    case .before:
      scrollMetricsMutator.applyOffset(-offset)

    case .after:
      scrollMetricsMutator.applyOffset(offset)

    case .partiallyOrFullyVisible(let frame):
      let targetPosition: CGFloat
      let currentPosition: CGFloat
      switch content.monthsLayout {
      case .vertical:
        targetPosition = anchorLayoutItem(
          for: scrollToItemContext,
          visibleItemsProvider: visibleItemsProvider)
          .frame.minY
        currentPosition = frame.minY
      case .horizontal:
        targetPosition = anchorLayoutItem(
          for: scrollToItemContext,
          visibleItemsProvider: visibleItemsProvider)
          .frame.minX
        currentPosition = frame.minX
      }
      let distanceToTargetPosition = currentPosition - targetPosition
      if distanceToTargetPosition <= -1 {
        scrollMetricsMutator.applyOffset(max(-offset, distanceToTargetPosition))
      } else if distanceToTargetPosition >= 1 {
        scrollMetricsMutator.applyOffset(min(offset, distanceToTargetPosition))
      } else {
        finalizeScrollingTowardItem(for: scrollToItemContext)
      }

    case .none:
      break
    }

    setNeedsLayout()
    layoutIfNeeded()

    // If we overshoot our target item, then finalize the animation immediately. In practice, this
    // will only happen if the maximum per-animation-tick offset is greater than the viewport size.
    let positionAfterLayout = positionRelativeToVisibleBounds(for: scrollToItemContext.targetItem)
    switch (positionBeforeLayout, positionAfterLayout) {
    case (.before, .after), (.after, .before):
      finalizeScrollingTowardItem(for: scrollToItemContext)

      // Force layout immediately to prevent the overshoot from being visible to the user.
      setNeedsLayout()
      layoutIfNeeded()

    default:
      break
    }
  }

  private func maintainScrollPositionAfterBoundsOrMarginsChange() {
    guard
      !scrollView.isDragging,
      let framesForVisibleMonths = visibleItemsDetails?.framesForVisibleMonths,
      let firstVisibleMonth = visibleMonthRange?.lowerBound,
      let frameOfFirstVisibleMonth = framesForVisibleMonths[firstVisibleMonth]
    else {
      return
    }

    let paddingFromFirstEdge: CGFloat
    switch content.monthsLayout {
    case .vertical:
      paddingFromFirstEdge = frameOfFirstVisibleMonth.minY -
        scrollView.contentOffset.y -
        (visibleItemsDetails?.heightOfPinnedContent ?? 0)
    case .horizontal:
      paddingFromFirstEdge = frameOfFirstVisibleMonth.minX - scrollView.contentOffset.x
    }

    if let existingScrollToItemContext = scrollToItemContext {
      let scrollPosition: CalendarViewScrollPosition
      switch existingScrollToItemContext.scrollPosition {
      case .firstFullyVisiblePosition:
        scrollPosition = .firstFullyVisiblePosition(padding: paddingFromFirstEdge)
      default:
        scrollPosition = existingScrollToItemContext.scrollPosition
      }

      scrollToItemContext = ScrollToItemContext(
        targetItem: existingScrollToItemContext.targetItem,
        scrollPosition: scrollPosition,
        animated: false)
    } else {
      scrollToItemContext = ScrollToItemContext(
        targetItem: .month(firstVisibleMonth),
        scrollPosition: .firstFullyVisiblePosition(padding: paddingFromFirstEdge),
        animated: false)
    }
  }

  private func configureMultiDaySelectionPanGestureRecognizer() {
    if multiDaySelectionDragHandler == nil {
      removeGestureRecognizer(multiDaySelectionLongPressGestureRecognizer)
      removeGestureRecognizer(multiDaySelectionPanGestureRecognizer)
    } else {
      addGestureRecognizer(multiDaySelectionLongPressGestureRecognizer)
      addGestureRecognizer(multiDaySelectionPanGestureRecognizer)
    }
  }

  @objc
  private func multiDaySelectionGestureRecognized(_ gestureRecognizer: UIGestureRecognizer) {
    guard gestureRecognizer.state != .possible else { return }

    // If the user interacts with the drag gesture, we should clear out any existing
    // `scrollToItemContext` that might be leftover from the initial layout process.
    scrollToItemContext = nil

    updateSelectedDayRange(gestureRecognizer: gestureRecognizer)
    updateAutoScrollingState(gestureRecognizer: gestureRecognizer)

    switch gestureRecognizer.state {
    case .ended, .cancelled, .failed:
      if let lastMultiDaySelectionDay {
        multiDaySelectionDragHandler?(lastMultiDaySelectionDay, gestureRecognizer.state)
      }
      lastMultiDaySelectionDay = nil

    default:
      break
    }
  }

  private func updateSelectedDayRange(gestureRecognizer: UIGestureRecognizer) {
    // Find the intersected day
    var intersectedDay: Day?
    for subview in scrollView.subviews {
      guard
        !subview.isHidden,
        let itemView = subview as? ItemView,
        case .layoutItemType(.day(let day)) = itemView.itemType,
        itemView.hitTest(gestureRecognizer.location(in: itemView), with: nil) != nil
      else {
        continue
      }
      intersectedDay = day
      break
    }

    if let intersectedDay, intersectedDay != lastMultiDaySelectionDay {
      lastMultiDaySelectionDay = intersectedDay
      multiDaySelectionDragHandler?(intersectedDay, gestureRecognizer.state)
    } else if gestureRecognizer.state == .began {
      // If the gesture doesn't intersect a day in the `began` state, cancel it
      gestureRecognizer.isEnabled = false
      gestureRecognizer.isEnabled = true
    }
  }

  private func updateAutoScrollingState(gestureRecognizer: UIGestureRecognizer) {
    func enableAutoScroll(offset: CGFloat) {
      autoScrollOffset = offset

      if autoScrollDisplayLink == nil {
        let autoScrollDisplayLink = CADisplayLink(
          target: self,
          selector: #selector(autoScrollDisplayLinkFired))
        autoScrollDisplayLink.add(to: .main, forMode: .common)
        self.autoScrollDisplayLink = autoScrollDisplayLink
      }
    }

    func disableAutoScroll() {
      autoScrollDisplayLink?.invalidate()
      autoScrollOffset = nil
    }

    switch gestureRecognizer.state {
    case .changed:
      let edgeMargin: CGFloat = 32
      let offset: CGFloat = 6
      let locationInCalendarView = gestureRecognizer.location(in: self)
      switch content.monthsLayout {
      case .vertical:
        if locationInCalendarView.y < layoutMargins.top + edgeMargin {
          enableAutoScroll(offset: -offset)
        } else if locationInCalendarView.y > bounds.height - layoutMargins.bottom - edgeMargin {
          enableAutoScroll(offset: offset)
        } else {
          disableAutoScroll()
        }

      case .horizontal:
        if locationInCalendarView.x < layoutMargins.left + edgeMargin {
          enableAutoScroll(offset: -offset)
        } else if locationInCalendarView.x > bounds.width - layoutMargins.right - edgeMargin {
          enableAutoScroll(offset: offset)
        } else {
          disableAutoScroll()
        }
      }

    default:
      disableAutoScroll()
    }
  }

  @objc
  private func autoScrollDisplayLinkFired() {
    guard let autoScrollOffset else {
      fatalError("The autoScrollDisplayLink should not fire if `autoScrollOffset` is `nil`.")
    }

    scrollMetricsMutator.applyOffset(autoScrollOffset)

    if multiDaySelectionLongPressGestureRecognizer.state != .possible {
      updateSelectedDayRange(gestureRecognizer: multiDaySelectionLongPressGestureRecognizer)
    } else if multiDaySelectionPanGestureRecognizer.state != .possible {
      updateSelectedDayRange(gestureRecognizer: multiDaySelectionPanGestureRecognizer)
    } else {
      fatalError("The autoScrollDisplayLink should not fire if both gesture recognizers are in the `.possible` state.")
    }
  }

}

// MARK: WidthDependentIntrinsicContentHeightProviding

extension CalendarView: WidthDependentIntrinsicContentHeightProviding {

  // This is where we perform our width-dependent height calculation. See `DoubleLayoutPassHelpers`
  // for more details about why this is needed and how it works.
  func intrinsicContentSize(forHorizontallyInsetWidth width: CGFloat) -> CGSize {
    let calendarWidth = width + layoutMargins.left + layoutMargins.right
    let calendarHeight: CGFloat
    if content.monthsLayout.isHorizontal {
      calendarHeight = .maxLayoutValue
    } else {
      calendarHeight = bounds.height
    }

    let visibleItemsProvider = VisibleItemsProvider(
      calendar: calendar,
      content: content,
      size: CGSize(width: calendarWidth, height: calendarHeight),
      layoutMargins: directionalLayoutMargins,
      scale: scale,
      backgroundColor: backgroundColor)

    let anchorMonthHeaderLayoutItem = anchorLayoutItem(
      for: .init(
        targetItem: .month(content.monthRange.lowerBound),
        scrollPosition: .firstFullyVisiblePosition,
        animated: false),
      visibleItemsProvider: visibleItemsProvider)

    let visibleItemsDetails = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: anchorMonthHeaderLayoutItem,
      offset: scrollView.contentOffset,
      extendLayoutRegion: false)

    return CGSize(width: UIView.noIntrinsicMetric, height: visibleItemsDetails.intrinsicHeight)
  }

}

// MARK: UIAccessibility

extension CalendarView {

  // MARK: Public

  public override var isAccessibilityElement: Bool {
    get { false }
    set { }
  }

  public override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
    guard
      let firstVisibleMonth = visibleMonthRange?.lowerBound,
      let lastVisibleMonth = visibleMonthRange?.upperBound,
      let firstVisibleMonthDate = calendar.date(from: firstVisibleMonth.components),
      let lastVisibleMonthDate = calendar.date(from: lastVisibleMonth.components),
      let numberOfVisibleMonths = calendar.dateComponents(
        [.month],
        from: firstVisibleMonthDate,
        to: lastVisibleMonthDate)
        .month
    else {
      return false
    }

    let proposedTargetMonth: Month
    let scrollPosition: CalendarViewScrollPosition
    switch (direction, content.monthsLayout) {
    case (.up, .vertical), (.right, .horizontal):
      proposedTargetMonth = Month(
        era: lastVisibleMonth.era,
        year: lastVisibleMonth.year,
        month: lastVisibleMonth.month - numberOfVisibleMonths,
        isInGregorianCalendar: lastVisibleMonth.isInGregorianCalendar)
      scrollPosition = .lastFullyVisiblePosition

    case (.down, .vertical), (.left, .horizontal):
      proposedTargetMonth = Month(
        era: firstVisibleMonth.era,
        year: firstVisibleMonth.year,
        month: firstVisibleMonth.month + numberOfVisibleMonths,
        isInGregorianCalendar: firstVisibleMonth.isInGregorianCalendar)
      scrollPosition = .firstFullyVisiblePosition

    default:
      return false
    }

    let firstMonth = content.monthRange.lowerBound
    let lastMonth = content.monthRange.upperBound
    let targetMonth = max(firstMonth, min(lastMonth, proposedTargetMonth))
    guard let targetMonthDate = calendar.date(from: targetMonth.components) else { return false }

    scroll(toMonthContaining: targetMonthDate, scrollPosition: scrollPosition, animated: false)

    let targetMonthItem = content.monthHeaderItemProvider(targetMonth)
    let targetMonthView = targetMonthItem._makeView()
    targetMonthItem._setContent(onViewOfSameType: targetMonthView)
    let accessibilityScrollText = targetMonthView.accessibilityLabel
    UIAccessibility.post(notification: .pageScrolled, argument: accessibilityScrollText)

    // ensure that scrolling related callbacks are still fired when performing scrolling via accessibility
    if let visibleDayRange {
      didScroll?(visibleDayRange, false)
      didEndDragging?(visibleDayRange, true)
      didEndDecelerating?(visibleDayRange)
    }

    return true
  }

  // MARK: Private

  @objc
  private func accessibilityElementFocused(_ notification: NSNotification) {
    guard
      let element = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey] as? UIResponder,
      let itemView = element.nextItemView()
    else {
      return
    }

    initialItemViewWasFocused = true

    // If the accessibility element is not fully in view, programmatically scroll it to be centered.
    let isElementFullyVisible: Bool
    let viewFrameInCalendarView = itemView.convert(itemView.bounds, to: self)
    switch scrollMetricsMutator.scrollAxis {
    case .vertical:
      let verticalBounds = CGRect(
        x: 0,
        y: layoutMargins.top,
        width: bounds.width,
        height: bounds.height - layoutMargins.top - layoutMargins.bottom)
      isElementFullyVisible = verticalBounds.contains(viewFrameInCalendarView)
    case .horizontal:
      let horizontalBounds = CGRect(
        x: layoutMargins.left,
        y: 0,
        width: bounds.width - layoutMargins.left - layoutMargins.right,
        height: bounds.height)
      isElementFullyVisible = horizontalBounds.contains(viewFrameInCalendarView)
    }

    if
      !isElementFullyVisible,
      let itemType = itemView.itemType,
      case .layoutItemType(let layoutItemType) = itemType
    {
      switch layoutItemType {
      case .monthHeader(let month):
        let dateInTargetMonth = calendar.firstDate(of: month)
        scroll(toMonthContaining: dateInTargetMonth, scrollPosition: .centered, animated: false)
      case .day(let day):
        let dateInTargetDay = calendar.startDate(of: day)
        scroll(toDayContaining: dateInTargetDay, scrollPosition: .centered, animated: false)
      default:
        break
      }
    }
  }

}

// MARK: - ScrollViewDelegate

/// Rather than making `CalendarView` conform to `UIScrollViewDelegate`, which would expose those methods as public, we
/// use a separate delegate object to hide these methods from the public API.
private final class ScrollViewDelegate: NSObject, UIScrollViewDelegate {

  // MARK: Lifecycle

  init(calendarView: CalendarView) {
    self.calendarView = calendarView
  }

  // MARK: Internal

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard let calendarView else { return }

    calendarView.preventLargeOverScrollIfNeeded()

    let isUserInitiatedScrolling = scrollView.isDragging && scrollView.isTracking

    if let visibleDayRange = calendarView.visibleDayRange {
      calendarView.didScroll?(visibleDayRange, isUserInitiatedScrolling)
    }

    if isUserInitiatedScrolling {
      // If the user interacts with the scroll view, we should clear out any existing
      // `scrollToItemContext` that might be leftover from the initial layout process.
      calendarView.scrollToItemContext = nil
    }

    calendarView.setNeedsLayout()
  }

  func scrollViewDidEndDragging(
    _: UIScrollView,
    willDecelerate decelerate: Bool)
  {
    guard let calendarView, let visibleDayRange = calendarView.visibleDayRange else { return }
    calendarView.didEndDragging?(visibleDayRange, decelerate)
  }

  func scrollViewDidEndDecelerating(_: UIScrollView) {
    guard let calendarView, let visibleDayRange = calendarView.visibleDayRange else { return }
    calendarView.didEndDecelerating?(visibleDayRange)
  }

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    guard
      let calendarView,
      case .horizontal(let options) = calendarView.content.monthsLayout,
      case .paginatedScrolling = options.scrollingBehavior
    else {
      return
    }

    let pageSize = options.pageSize(
      calendarWidth: calendarView.bounds.width,
      interMonthSpacing: calendarView.content.interMonthSpacing)
    calendarView.previousPageIndex = PaginationHelpers.closestPageIndex(
      forOffset: scrollView.contentOffset.x,
      pageSize: pageSize)
  }

  func scrollViewWillEndDragging(
    _ scrollView: UIScrollView,
    withVelocity velocity: CGPoint,
    targetContentOffset: UnsafeMutablePointer<CGPoint>)
  {
    guard
      let calendarView,
      case .horizontal(let options) = calendarView.content.monthsLayout,
      case .paginatedScrolling(let paginationConfiguration) = options.scrollingBehavior
    else {
      return
    }

    let pageSize = options.pageSize(
      calendarWidth: calendarView.bounds.width,
      interMonthSpacing: calendarView.content.interMonthSpacing)

    switch paginationConfiguration.restingAffinity {
    case .atPositionsAdjacentToPrevious:
      guard let previousPageIndex = calendarView.previousPageIndex else {
        preconditionFailure("""
            `previousPageIndex` was accessed before being set in `scrollViewWillBeginDragging`.
          """)
      }
      targetContentOffset.pointee.x = PaginationHelpers.adjacentPageOffset(
        toPreviousPageIndex: previousPageIndex,
        targetOffset: targetContentOffset.pointee.x,
        velocity: velocity.x,
        pageSize: pageSize)

    case .atPositionsClosestToTargetOffset:
      targetContentOffset.pointee.x = PaginationHelpers.closestPageOffset(
        toTargetOffset: targetContentOffset.pointee.x,
        touchUpOffset: scrollView.contentOffset.x,
        velocity: velocity.x,
        pageSize: pageSize)
    }
  }

  func scrollViewShouldScrollToTop(_: UIScrollView) -> Bool {
    guard let calendarView else { return false }

    if calendarView.content.monthsLayout.scrollsToFirstMonthOnStatusBarTap {
      let firstMonth = calendarView.content.monthRange.lowerBound
      let firstDate = calendarView.calendar.firstDate(of: firstMonth)
      calendarView.scroll(
        toMonthContaining: firstDate,
        scrollPosition: .firstFullyVisiblePosition(padding: 0),
        animated: true)
    }

    return false
  }

  // MARK: Private

  private weak var calendarView: CalendarView?

}

// MARK: - GestureRecognizerDelegate

/// Rather than making `CalendarView` conform to `UIGestureRecognizerDelegate`, which would expose those methods as
/// public, we use a separate delegate object to hide these methods from the public API.
private final class GestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {

  // MARK: Lifecycle

  init(calendarView: CalendarView) {
    self.calendarView = calendarView
  }

  // MARK: Internal

  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
    -> Bool
  {
    guard let calendarView else { return false }

    let isGestureRecognizerMultiSelectGesture =
      gestureRecognizer === calendarView.multiDaySelectionLongPressGestureRecognizer ||
      gestureRecognizer === calendarView.multiDaySelectionPanGestureRecognizer
    let isOtherGestureRecognizerScrollViewPanGesture =
      otherGestureRecognizer === calendarView.scrollView.panGestureRecognizer
    let isMultiSelectingAndScrolling =
      isGestureRecognizerMultiSelectGesture &&
      isOtherGestureRecognizerScrollViewPanGesture &&
      gestureRecognizer.state == .changed
    return isMultiSelectingAndScrolling
  }

  // MARK: Private

  private weak var calendarView: CalendarView?

}

// MARK: Scroll View Silent Updating

extension UIScrollView {

  fileprivate func performWithoutNotifyingDelegate(_ operations: () -> Void) {
    let delegate = delegate
    self.delegate = nil

    operations()

    self.delegate = delegate
  }

}

// MARK: `UIResponder` Next `ItemView`

extension UIResponder {

  fileprivate func nextItemView() -> ItemView? {
    self as? ItemView ?? next?.nextItemView()
  }

}
