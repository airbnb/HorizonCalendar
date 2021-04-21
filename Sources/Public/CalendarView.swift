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

/// A declarative, performant, calendar UI component that supports use cases ranging from simple date pickers all the way up to
/// fully-featured calendar apps. Its declarative API makes updating the calendar straightforward, while also providing many
/// customization points to support a diverse set of designs and use cases.
///
/// `CalendarView` does not handle any business logic related to day range selection or deselection. Instead, it provides a
/// single callback for day selection, allowing you to customize selection behavior in any way that you’d like.
///
/// Your business logic should respond to the day selection callback, regenerate `CalendarView` content based on changes to the
/// backing-models for your feature, then set the content on `CalendarView`. This will trigger `CalendarView` to re-render,
/// reflecting all new changes from the content you provide.
///
/// `CalendarView`’s content contains all information about how to render the calendar (you can think of `CalendarView` as a
/// pure function of its content). The two most important things provided by the content are:
/// * The date range to display
///   * e.g. September, 2019 - April, 2020
/// * The `CalendarItem` to display for each day in the date range
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

    (layer as! RenderInContextObservingLayer).willRenderInContext = { [weak self] in
      self?.sortScrollViewSublayersByZPositions()
    }

    if #available(iOS 13.0, *) {
      backgroundColor = .systemBackground
    } else {
      backgroundColor = .white
    }

    addSubview(scrollView)

    setContent(initialContent)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(accessibilityElementFocused(_:)),
      name: UIAccessibility.elementFocusedNotification,
    object: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Public

  public override class var layerClass: AnyClass { RenderInContextObservingLayer.self }

  /// A closure (that is retained) that is invoked whenever a day is selected.
  public var daySelectionHandler: ((Day) -> Void)?

  /// A closure (that is retained) that is invoked inside `scrollViewDidScroll(_:)`
  public var didScroll: ((_ visibleDayRange: DayRange, _ isUserDragging: Bool) -> Void)?

  /// A closure (that is retained) that is invoked inside `scrollViewDidEndDragging(_: willDecelerate:)`.
  public var didEndDragging: ((_ visibleDayRange: DayRange) -> Void)?

  /// A closure (that is retained) that is invoked inside `scrollViewDidEndDecelerating(_:)`.
  public var didEndDecelerating: ((_ visibleDayRange: DayRange) -> Void)?

  /// Whether or not the calendar's scroll view is currently overscrolling, i.e, whether the rubber-banding or bouncing effect is in
  /// progress.
  public var isOverscrolling: Bool {
    let scrollAxis = scrollMetricsMutator.scrollAxis
    let offset = scrollView.offset(for: scrollAxis)

    return offset < scrollView.minimumOffset(for: scrollAxis) ||
      offset > scrollView.maximumOffset(for: scrollAxis)
  }

  /// The range of months that are partially of fully visible.
  public var visibleMonthRange: MonthRange? {
    visibleItemsDetails?.visibleMonthRange
  }

  /// The range of days that are partially or fully visible.
  public var visibleDayRange: DayRange? {
    visibleItemsDetails?.visibleDayRange
  }

  public override var bounds: CGRect {
    willSet {
      // If the bounds' size changes (on rotation, for example), our existing anchor layout item
      // will have a stale frame, which will result in incorrect layout calculations in
      // `layoutSubviews`. To account for this, we programmatically scroll to the first visible
      // month when the bounds' size changes.
      guard
        newValue.size != bounds.size,
        scrollToItemContext == nil,
        !scrollView.isDragging,
        let framesForVisibleMonths = visibleItemsDetails?.framesForVisibleMonths,
        let firstVisibleMonth = visibleMonthRange?.lowerBound,
        let frameOfFirstVisibleMonth = framesForVisibleMonths[firstVisibleMonth]
      else
      {
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

      scrollToItemContext = ScrollToItemContext(
        targetItem: .month(firstVisibleMonth),
        scrollPosition: .firstFullyVisiblePosition(padding: paddingFromFirstEdge),
        animated: false)
    }
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
    setNeedsLayout()
  }

  public override func layoutSubviews() {
    super.layoutSubviews()

    // Setting the scroll view's frame in `layoutSubviews` causes overscrolling to not work. We
    // work around this by only setting the frame if it's changed.
    if scrollView.frame != bounds {
      scrollView.frame = bounds
    }

    if traitCollection.layoutDirection == .rightToLeft {
      scrollView.transform = .init(scaleX: -1, y: 1)
    } else {
      scrollView.transform = .identity
    }

    guard isReadyForLayout else { return }

    scrollView.performWithoutNotifyingDelegate {
      scrollMetricsMutator.setUpInitialMetricsIfNeeded()
      scrollMetricsMutator.updateContentSizePerpendicularToScrollAxis(viewportSize: bounds.size)
    }

    let anchorLayoutItem: LayoutItem
    if let scrollToItemContext = scrollToItemContext, !scrollToItemContext.animated {
      anchorLayoutItem = self.anchorLayoutItem(for: scrollToItemContext)
    } else if let previousAnchorLayoutItem = self.anchorLayoutItem {
      anchorLayoutItem = previousAnchorLayoutItem
    } else {
      let initialScrollToItemContext = ScrollToItemContext(
        targetItem: .month(content.monthRange.lowerBound),
        scrollPosition: .firstFullyVisiblePosition,
        animated: false)
      anchorLayoutItem = self.anchorLayoutItem(for: initialScrollToItemContext)
    }

    let currentVisibleItemsDetails = visibleItemsProvider.detailsForVisibleItems(
      surroundingPreviouslyVisibleLayoutItem: anchorLayoutItem,
      offset: scrollView.contentOffset)
    self.anchorLayoutItem = currentVisibleItemsDetails.centermostLayoutItem

    updateVisibleViews(
      withVisibleItems: currentVisibleItemsDetails.visibleItems,
      previouslyVisibleItems: visibleItemsDetails?.visibleItems ?? [])

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

    cachedAccessibilityElements = nil
    if let element = focusedAccessibilityElement as? OffScreenCalendarItemAccessibilityElement {
      UIAccessibility.post(
        notification: .layoutChanged,
        argument: visibleViewsForVisibleItems[element.correspondingItem])
    }
  }

  /// Sets the content of the `CalendarView`, causing it to re-render.
  ///
  /// - Parameters:
  ///   - content: The content to use when rendering `CalendarView`.
  public func setContent(_ content: CalendarViewContent) {
    self.content = content

    if let contentBackgroundColor = content.backgroundColor {
      backgroundColor = contentBackgroundColor
    }

    _visibleItemsProvider = nil
    scrollToItemContext = nil

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

    if !isAnchorLayoutItemValid {
      anchorLayoutItem = nil
    }

    if content.monthsLayout.isPaginationEnabled {
      scrollView.decelerationRate = .fast
    } else {
      scrollView.decelerationRate = .normal
    }

    setNeedsLayout()
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
    guard let visibleDayRange = visibleDayRange, visibleDayRange.contains(day) else { return nil }

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
    guard content.monthRange.contains(day.month) else {
      assertionFailure("""
        Attempted to scroll to day \(day), which is out of bounds of the total date range
        \(content.monthRange).
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

  // MARK: Private

  private let reuseManager = ItemViewReuseManager()

  private var content: CalendarViewContent

  private var _scrollMetricsMutator: ScrollMetricsMutator?
  private var previousPageIndex: Int?

  private var anchorLayoutItem: LayoutItem?
  private var _visibleItemsProvider: VisibleItemsProvider?
  private var visibleItemsDetails: VisibleItemsDetails?
  private var visibleViewsForVisibleItems = [VisibleCalendarItem: ItemView]()

  private weak var scrollToItemDisplayLink: CADisplayLink?
  private var scrollToItemAnimationStartTime: CFTimeInterval?

  private var cachedAccessibilityElements: [Any]?
  private var focusedAccessibilityElement: Any?

  private var scrollToItemContext: ScrollToItemContext? {
    willSet {
      scrollToItemDisplayLink?.invalidate()
    }
  }

  private lazy var scrollView: NoContentInsetAdjustmentScrollView = {
    let scrollView = NoContentInsetAdjustmentScrollView()
    scrollView.scrollsToTop = false
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.delegate = self
    return scrollView
  }()
  
  // Necessary to work around a `UIScrollView` behavior difference on Mac. See `scrollViewDidScroll`
  // and `preventLargeOverscrollIfNeeded` for more context.
  private lazy var isRunningOnMac: Bool = {
    if #available(iOS 13.0, *) {
      if ProcessInfo.processInfo.isMacCatalystApp {
        return true
      }
    }
    
    return false
  }()

  private var calendar: Calendar {
    content.calendar
  }

  private var isReadyForLayout: Bool {
    bounds.width > 0 && bounds.height > 0
  }

  private var scale: CGFloat {
    window?.screen.scale ?? UIScreen.main.scale
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
        monthHeaderHeight: monthHeaderHeight(),
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

  private func anchorLayoutItem(for scrollToItemContext: ScrollToItemContext) -> LayoutItem {
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
    guard let visibleItemsDetails = visibleItemsDetails else { return nil }

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

  private func monthHeaderHeight() -> CGFloat {
    let monthWidth: CGFloat
    switch content.monthsLayout {
    case .vertical:
      monthWidth = bounds.width
    case .horizontal(let options):
      monthWidth = options.monthWidth(
        calendarWidth: bounds.width,
        interMonthSpacing: content.interMonthSpacing)
    }

    let firstMonthHeaderItemModel = content.monthHeaderItemModelProvider(
      content.monthRange.lowerBound)
    let firstMonthHeader = firstMonthHeaderItemModel.makeView()
    firstMonthHeaderItemModel.setViewModelOnViewOfSameType(firstMonthHeader)

    let size = firstMonthHeader.systemLayoutSizeFitting(
      CGSize(width: monthWidth, height: 0),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel)
    return size.height
  }

  private func updateVisibleViews(
    withVisibleItems visibleItems: Set<VisibleCalendarItem>,
    previouslyVisibleItems: Set<VisibleCalendarItem>)
  {
    var visibleItemsWithViewsToRemove = previouslyVisibleItems
    let previousVisibleViewsForVisibleItems = visibleViewsForVisibleItems

    visibleViewsForVisibleItems.removeAll(keepingCapacity: true)

    reuseManager.viewsForVisibleItems(
      visibleItems,
      viewHandler: { view, visibleItem, previousBackingVisibleItem in
        if view.superview == nil {
          UIView.performWithoutAnimation {
            scrollView.addSubview(view)
          }
        }

        configureView(view, with: visibleItem)

        visibleViewsForVisibleItems[visibleItem] = view

        if let previousBackingVisibleItem = previousBackingVisibleItem {
          visibleItemsWithViewsToRemove.remove(previousBackingVisibleItem)
        }
      })

    // Remove any old views that weren't reused
    for visibleItemWithViewToRemove in visibleItemsWithViewsToRemove {
      previousVisibleViewsForVisibleItems[visibleItemWithViewToRemove]?.removeFromSuperview()
    }
  }

  private func configureView(_ view: ItemView, with visibleItem: VisibleCalendarItem) {
    view.calendarItemModel = visibleItem.calendarItemModel

    // Update the visibility
    UIView.performWithoutAnimation {
      view.frame = visibleItem.frame.alignedToPixels(forScreenWithScale: scale)
      view.layer.zPosition = visibleItem.itemType.zPosition

      if traitCollection.layoutDirection == .rightToLeft {
        view.transform = .init(scaleX: -1, y: 1)
      } else {
        view.transform = .identity
      }
    }

    view.isUserInteractionEnabled = visibleItem.itemType.isUserInteractionEnabled

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
      let scrollToItemContext = scrollToItemContext,
      let animationStartTime = scrollToItemAnimationStartTime
    else
    {
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
        targetPosition = anchorLayoutItem(for: scrollToItemContext).frame.minY
        currentPosition = frame.minY
      case .horizontal:
        targetPosition = anchorLayoutItem(for: scrollToItemContext).frame.minX
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

      // Force layout immdiately to prevent the overshoot from being visible to the user.
      setNeedsLayout()
      layoutIfNeeded()

    default:
      break
    }
  }
  
  // This hack is needed to prevent the scroll view from overscrolling far past the content. This
  // occurs in 2 scenarios:
  // - On macOS if you scroll quickly toward a boundary
  // - On iOS if you scroll quickly toward a boundary and targetContentOffset is mutated
  //
  // https://openradar.appspot.com/radar?id=4966130615582720 demonstrates this issue on macOS.
  private func preventLargeOverscrollIfNeeded() {
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
    
    if let newOffset = newOffset {
      scrollView.performWithoutNotifyingDelegate {
        // Passing `false` for `animated` is necessary to stop the in-flight deceleration animation
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut], animations: {
          self.scrollView.setContentOffset(newOffset, animated: false)
        })
      }
    }
  }

  /// This is needed to ensure that the `scrollView.sublayers` array is sorted according to each sublayer's `zPosition`.
  /// This prevents z-index-related rendering issues when a `CalendarView` is being snapshotted via `CALayer.render(in:)`.
  private func sortScrollViewSublayersByZPositions() {
    scrollView.layer.sublayers?.sort { $0.zPosition < $1.zPosition }
  }

}

// MARK: UIScrollViewDelegate

extension CalendarView: UIScrollViewDelegate {

  @available(
    *,
    deprecated,
    message: "Do not invoke this function directly, as it is only intended to be called from the internal implementation of `CalendarView`. This will be removed in a future major release.")
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    preventLargeOverscrollIfNeeded()

    let isUserInitiatedScrolling = scrollView.isDragging && scrollView.isTracking

    if let visibleDayRange = visibleDayRange {
      didScroll?(visibleDayRange, isUserInitiatedScrolling)
    }

    if isUserInitiatedScrolling {
      // If the user interacts with the scroll view, we should clear out any existing
      // `scrollToItemContext` that might be leftover from the initial layout process.
      scrollToItemContext = nil
    }

    setNeedsLayout()
  }

  @available(
    *,
    deprecated,
    message: "Do not invoke this function directly, as it is only intended to be called from the internal implementation of `CalendarView`. This will be removed in a future major release.")
  public func scrollViewDidEndDragging(
    _ scrollView: UIScrollView,
    willDecelerate decelerate: Bool)
  {
    guard let visibleDayRange = visibleDayRange else { return }
    didEndDragging?(visibleDayRange)
  }

  @available(
    *,
    deprecated,
    message: "Do not invoke this function directly, as it is only intended to be called from the internal implementation of `CalendarView`. This will be removed in a future major release.")
  public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard let visibleDayRange = visibleDayRange else { return }
    didEndDecelerating?(visibleDayRange)
  }
  
  @available(
    *,
    deprecated,
    message: "Do not invoke this function directly, as it is only intended to be called from the internal implementation of `CalendarView`. This will be removed in a future major release.")
  public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    guard
      case .horizontal(let options) = content.monthsLayout,
      case .paginatedScrolling = options.scrollingBehavior
    else
    {
      return
    }

    let pageSize = options.pageSize(
      calendarWidth: bounds.width,
      interMonthSpacing: content.interMonthSpacing)
    previousPageIndex = PaginationHelpers.closestPageIndex(
      forOffset: scrollView.contentOffset.x,
      pageSize: pageSize)
  }

  @available(
    *,
    deprecated,
    message: "Do not invoke this function directly, as it is only intended to be called from the internal implementation of `CalendarView`. This will be removed in a future major release.")
  public func scrollViewWillEndDragging(
    _ scrollView: UIScrollView,
    withVelocity velocity: CGPoint,
    targetContentOffset: UnsafeMutablePointer<CGPoint>)
  {
    guard
      case .horizontal(let options) = content.monthsLayout,
      case .paginatedScrolling(let paginationConfiguration) = options.scrollingBehavior
    else
    {
      return
    }
    
    let pageSize = options.pageSize(
      calendarWidth: bounds.width,
      interMonthSpacing: content.interMonthSpacing)
    
    switch paginationConfiguration.restingAffinity {
    case .atPositionsAdjacentToPrevious:
      guard let previousPageIndex = previousPageIndex else {
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

}

// MARK: UIAccessibility

extension CalendarView {

  public override var isAccessibilityElement: Bool {
    get { false }
    set { }
  }

  public override var accessibilityElements: [Any]? {
    get {
      guard cachedAccessibilityElements == nil else {
        return cachedAccessibilityElements
      }
      guard
        let visibleItemsDetails = visibleItemsDetails,
        let visibleMonthRange = visibleMonthRange
      else
      {
        return nil
      }

      let visibleItems = visibleItemsProvider.visibleItemsForAccessibilityElements(
        surroundingPreviouslyVisibleLayoutItem: visibleItemsDetails.centermostLayoutItem,
        visibleMonthRange: visibleMonthRange)

      var elements = [Any]()
      for visibleCalendarItem in visibleItems {
        guard case .layoutItemType = visibleCalendarItem.itemType else {
          assertionFailure("""
            Only visible calendar items with itemType == .layoutItemType should be considered for
            use as an accessibility element.
          """)
          continue
        }
        let element: Any
        if let visibleView = visibleViewsForVisibleItems[visibleCalendarItem] {
          element = visibleView
        } else {
          guard
            let accessibilityElement = OffScreenCalendarItemAccessibilityElement(
              correspondingItem: visibleCalendarItem,
              scrollViewContainer: scrollView)
          else
          {
            continue
          }

          accessibilityElement.accessibilityFrameInContainerSpace = CGRect(
            x: visibleCalendarItem.frame.minX - scrollView.contentOffset.x,
            y: visibleCalendarItem.frame.minY - scrollView.contentOffset.y,
            width: visibleCalendarItem.frame.width,
            height: visibleCalendarItem.frame.height)
          element = accessibilityElement
        }

        elements.append(element)
      }

      cachedAccessibilityElements = elements

      return elements
    }
    set { }
  }

  public override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
    let contentOffset: CGPoint
    switch (direction, content.monthsLayout) {
    case (.up, .vertical):
      contentOffset = CGPoint(
        x: scrollView.contentOffset.x,
        y: max(
          scrollView.contentOffset.y - scrollView.bounds.height,
          -scrollView.contentInset.top))
    case (.down, .vertical):
      contentOffset = CGPoint(
        x: scrollView.contentOffset.x,
        y: min(
          scrollView.contentOffset.y + scrollView.bounds.height,
          scrollView.contentSize.height +
            scrollView.contentInset.bottom -
            scrollView.bounds.height))
    case (.left, .horizontal):
      contentOffset = CGPoint(
          x: max(
            scrollView.contentOffset.x - scrollView.bounds.width,
            -scrollView.contentInset.left),
          y: scrollView.contentOffset.y)
    case (.right, .horizontal):
      contentOffset = CGPoint(
        x: min(
          scrollView.contentOffset.x + scrollView.bounds.width,
          scrollView.contentSize.width + scrollView.contentInset.right - scrollView.bounds.width),
        y: scrollView.contentOffset.y)
    default:
      contentOffset = scrollView.contentOffset
    }

    if contentOffset != scrollView.contentOffset {
      scrollView.setContentOffset(contentOffset, animated: true)
      return true
    } else {
      return false
    }
  }

  @objc
  private func accessibilityElementFocused(_ notification: NSNotification) {
    guard let element = notification.userInfo?[UIAccessibility.focusedElementUserInfoKey] else {
      return
    }
    focusedAccessibilityElement = element

    guard let offScreenElement = element as? OffScreenCalendarItemAccessibilityElement else {
      return
    }

    switch offScreenElement.correspondingItem.itemType {
    case .layoutItemType(.monthHeader(let month)):
      let dateInTargetMonth = calendar.firstDate(of: month)
      scroll(toMonthContaining: dateInTargetMonth, scrollPosition: .centered, animated: false)
    case .layoutItemType(.day(let day)):
      let dateInTargetDay = calendar.startDate(of: day)
      scroll(toDayContaining: dateInTargetDay, scrollPosition: .centered, animated: false)
    default:
      break
    }
  }

}

// MARK: - NoContentInsetAdjustmentScrollView

/// A scroll view that forces `contentInsetAdjustmentBehavior == .never`.
///
/// The main thing this prevents is the situation where the view hierachy is traversed to find a scroll view, and attempts are made to
/// change that scroll view's `contentInsetAdjustmentBehavior`.
private final class NoContentInsetAdjustmentScrollView: UIScrollView {

  // MARK: Lifecycle

  init() {
    super.init(frame: .zero)
    contentInsetAdjustmentBehavior = .never
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  override var contentInsetAdjustmentBehavior: ContentInsetAdjustmentBehavior {
    didSet {
      super.contentInsetAdjustmentBehavior = .never
    }
  }

}

// MARK: Scroll View Silent Updating

private extension UIScrollView {

  func performWithoutNotifyingDelegate(_ operations: () -> Void) {
    let delegate = self.delegate
    self.delegate = nil

    operations()

    self.delegate = delegate
  }

}
