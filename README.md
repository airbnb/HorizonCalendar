# HorizonCalendar
A declarative, performant, calendar UI component that supports use cases ranging from simple date pickers all the way up to fully-featured calendar apps.

[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-4BC51D.svg?style=flat)](https://github.com/apple/swift-package-manager)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Version](https://img.shields.io/cocoapods/v/HorizonCalendar.svg)](https://cocoapods.org/pods/HorizonCalendar)
[![License](https://img.shields.io/cocoapods/l/HorizonCalendar.svg)](https://cocoapods.org/pods/HorizonCalendar)
[![Platform](https://img.shields.io/cocoapods/p/HorizonCalendar.svg)](https://cocoapods.org/pods/HorizonCalendar)
![Swift](https://github.com/airbnb/HorizonCalendar/workflows/Swift/badge.svg)

## Introduction
`HorizonCalendar` is UIKit library for displaying a range of dates in a vertically-scrolling or horizontally-scrolling calendar component. Its declarative API makes updating the calendar straightforward, while also providing many customization points to support a diverse set of designs and use cases.

Features:

- Supports all calendars from `Foundation.Calendar` (Gregorian, Japanese, Hebrew, etc.)
- Display months in a vertically-scrolling or horizontally-scrolling layout
- Declarative API that enables unidirectional data flow for updating the content of the calendar
- A custom layout system that enables virtually infinite date ranges without increasing memory usage
- Pagination for horizontally-scrolling calendars
- Specify custom views for individual days, month headers, and days of the week
- Specify custom views to highlight date ranges
- Specify custom views to overlay parts of the calendar, enabling features like tooltips
- A day selection handler to monitor when a day is tapped
- Customizable layout metrics
- Pin the days-of-the-week row to the top
- Show partial boundary months (exactly 2020-03-14 to 2020-04-20, for example)
- Scroll to arbitrary dates and months, with or without animation
- Robust accessibility support
- Inset the content without affecting the scrollable region using `UIView` layout margins
- Separator below the days-of-the-week row
- Right-to-left layout support

`HorizonCalendar` serves as the foundation for the date pickers and calendars used in Airbnb's highest trafficked flows.

| Search | Stays Availability Calendar | Wish List | Experience Reservation | Experience Host Calendar Management |
| --- | --- | --- | --- | --- |
| ![Search](Docs/Images/stay_search.png) | ![Stay Availability Calendar](Docs/Images/stay_availability.png)  | ![Wish List](Docs/Images/wish_list.png) | ![Experience Reservation](Docs/Images/experience_reservation.png) | ![Experience Host Calendar Management](Docs/Images/experience_host.png) |

## Table of Contents
- [Example App](#example-app)
  - [Demos](#demos)
    - [Single Day Selection](#single-day-selection)
    - [Day Range Selection](#day-range-selection)
    - [Selected Day Tooltip](#selected-day-tooltip)
    - [Scroll to Day with Animation](#scroll-to-day-with-animation)
- [Integration Tutorial](#integration-tutorial)
  - [Requirements](#requirements)
  - [Installation](#installation)
    - [Carthage](#carthage)
    - [CocoaPods](#cocoapods)
  - [Building a `CalendarView`](#building-a-calendarView)
    - [Basic Setup](#basic-setup)
      - [Importing `HorizonCalendar`](#importing-horizoncalendar)
      - [Initializing a `CalendarView` with `CalendarViewContent`](#initializing-a-calendarview-with-calendarviewcontent)
    - [Customizing `CalendarView`](#customizing-calendarview)
      - [Providing a custom view for each day](#providing-a-custom-view-for-each-day)
      - [Adjusting layout metrics](#adjusting-layout-metrics)
      - [Adding a day range indicator](#adding-a-day-range-indicator)
      - [Adding a tooltip](#adding-a-tooltip)
    - [Responding to day selection](#responding-to-day-selection)
- [Technical Details](#technical-details)
- [Contributions](#contributions)
- [Authors](#authors)
- [Maintainers](#maintainers)
- [License](#license)

## Example App
An example app is available to showcase and enable you to test some of `HorizonCalendar`'s features. It can be found in `./Example/HorizonCalendarExample.xcworkspace`. 

Note: Make sure to use the `.xcworkspace` file, and not the `.xcodeproj` file, as the latter does not have access to `HorizonCalendar.framework`.

### Demos
The example app has several demo view controllers to try, with both vertical and horizontal layout variations:

![Demo Picker](Docs/Images/demo_picker.png)

#### Single Day Selection
| Vertical | Horizontal |
| ---- | ---- |
| ![Single Day Selection Vertical](Docs/Images/single_day_selection_vertical.png) | ![Single Day Selection Horizontal](Docs/Images/single_day_selection_horizontal.png) |

#### Day Range Selection
| Vertical | Horizontal |
| ---- | ---- |
| ![Day Range Selection Vertical](Docs/Images/day_range_selection_vertical.png) | ![Day Range Selection Horizontal](Docs/Images/day_range_selection_horizontal.png) |

#### Selected Day Tooltip
| Vertical | Horizontal |
| ---- | ---- |
| ![Selected Day Tooltip Vertical](Docs/Images/selected_day_tooltip_vertical.png) | ![Selected Day Tooltip Horizontal](Docs/Images/selected_day_tooltip_horizontal.png) |

#### Scroll to Day with Animation
| Vertical | Horizontal |
| ---- | ---- |
| ![Scroll to Day with Animation Vertical](Docs/Images/scroll_to_day_with_animation_vertical.gif) | ![Scroll to Day with Animation Horizontal](Docs/Images/scroll_to_day_with_animation_horizontal.gif) |

## Integration Tutorial

### Requirements
- Deployment target iOS 11.0+
- Swift 5+
- Xcode 10.2+

### Installation
#### Swift Package Manager
To install `HorizonCalendar` using [Swift Package Manager](https://swift.org/package-manager/), add
`.package(name: "HorizonCalendar", url: "https://github.com/airbnb/HorizonCalendar.git", from: "1.0.0"),"` to your Package.swift, then follow the integration tutorial [here](https://swift.org/package-manager#importing-dependencies).

#### Carthage
To install `HorizonCalendar` using [Carthage](https://github.com/Carthage/Carthage), add
`github "airbnb/HorizonCalendar"` to your Cartfile, then follow the integration tutorial [here](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos).

#### CocoaPods
To install `HorizonCalendar` using [CocoaPods](http://cocoapods.org), add
`pod 'HorizonCalendar'` to your Podfile, then follow the integration tutorial [here](https://guides.cocoapods.org/using/using-cocoapods.html).


## Building a `CalendarView`
Once you've installed `HorizonCalendar` into your project, getting a basic calendar working is just a few steps.

### Basic Setup

#### Importing `HorizonCalendar`
At the top of the file where you'd like to use `HorizonCalendar` (likely a `UIView` or `UIViewController` subclass), import `HorizonCalendar`:
```swift
import HorizonCalendar 
```

#### Initializing a `CalendarView` with `CalendarViewContent`
`CalendarView` is the `UIView` subclass that renders the calendar. All visual aspects of `CalendarView` are controlled through a single type - `CalendarViewContent`. To create a basic `CalendarView`, you initialize one with an initial `CalendarViewContent`:
```swift
let calendarView = CalendarView(initialContent: makeContent())
```

```swift
private func makeContent() -> CalendarViewContent {
  let calendar = Calendar.current

  let startDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 01))!
  let endDate = calendar.date(from: DateComponents(year: 2021, month: 12, day: 31))!

  return CalendarViewContent(
    calendar: calendar,
    visibleDateRange: startDate...endDate,
    monthsLayout: .vertical(options: VerticalMonthsLayoutOptions()))
}
```

At a minimum, `CalendarViewContent` must be initialized with a `Calendar`, a visible date range, and a months layout (either vertical or horizontal). The visible date range will be interpreted as a range of days using the `Calendar` instance passed in for the `calendar` parameter.

For this example, we're using a Gregorian calendar, a date range of 2020-01-01 to 2021-12-31, and a vertical months layout.

Make sure to add `calendarView` as a subview, then give it a valid frame either using Auto Layout or by manually setting its `frame` property. If you're using Auto Layout, note that `CalendarView` does not have an intrinsic content size.
```swift
view.addSubview(calendarView)

calendarView.translatesAutoresizingMaskIntoConstraints = false

NSLayoutConstraint.activate([
  calendarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
  calendarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
  calendarView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
  calendarView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
])
```

At this point, building and running your app should result in something that looks like this:

![Basic Calendar](Docs/Images/tutorial1.png)


### Customizing `CalendarView`

#### Providing a custom view for each day
`HorizonCalendar` comes with default views for month headers, day of week items, and day items. You can also provide custom views for each of these item types, enabling you to display whatever custom content makes sense for your app.

Since all visual aspects of `CalendarView` are configured through `CalendarViewContent`, we'll expand on our `makeContent` function. Let's start by providing a custom view for each day in the calendar:
```swift
private func makeContent() -> CalendarViewContent {
  return CalendarViewContent(
    calendar: calendar,
    visibleDateRange: today...endDate,
    monthsLayout: .vertical(VerticalMonthsLayoutOptions()))
    
    .withDayItemModelProvider { day in
      // Return a `CalendarItemModel` representing the view for each day
    }
}
```

The `withDayItemModelProvider(_:)` function on `CalendarViewContent` returns a new `CalendarViewContent` instance with the custom day item model provider configured. This function takes a single parameter - a provider closure that returns a `CalendarItemModel` for a given `Day`.

`CalendarItemModel` is a type that abstracts away the creation and configuration of a `UIView`. It's generic over a `ViewRepresentable` type, which can be any type conforming to `CalendarItemViewRepresentable`. You can think of `CalendarItemViewRepresentable` as a blueprint for creating and updating instances of a particular type of view to be displayed in the calendar. For example, if we want to use a `UILabel` for our custom day view, we'll need to create a type that knows how to create and update that label. Here's a simple example:
```swift
import HorizonCalendar

struct DayLabel: CalendarItemViewRepresentable {

  /// Properties that are set once when we initialize the view.
  struct InvariantViewProperties: Hashable {
    let font: UIFont
    let textColor: UIColor
    let backgroundColor: UIColor
  }

  /// Properties that will vary depending on the particular date being displayed.
  struct ViewModel: Equatable {
    let day: Day
  }

  static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> UILabel
  {
    let label = UILabel()

    label.backgroundColor = invariantViewProperties.backgroundColor
    label.font = invariantViewProperties.font
    label.textColor = invariantViewProperties.textColor

    label.textAlignment = .center
    label.clipsToBounds = true
    label.layer.cornerRadius = 12
    
    return label
  }

  static func setViewModel(_ viewModel: ViewModel, on view: UILabel) {
    view.text = "\(viewModel.day)"
  }

}
```

`CalendarItemViewRepresentable` requires us to implement a `static` `makeView` function, which should create and return a view given a set of invariant view properties. We want our label to have a configurable font and text color, so we've made those configurable via the `InvariantViewProperties` type. In our `makeView` function, we use those invariant view properties to create and configure an instance of our label.

`CalendarItemViewRepresentable` also requires us to implement a `static` `setViewModel` function, which should update all data-dependent properties (like the day text) on the provided view.

Now that we have a type conforming to `CalendarItemViewRepresentable`, we can use it to create a `CalendarItemModel` to return from the day item model provider:

```swift
  return CalendarViewContent(...)

    .withDayItemModelProvider { day in
      CalendarItemModel<DayLabel>(
        invariantViewProperties: .init(
          font: UIFont.systemFont(ofSize: 18), 
          textColor: .darkGray,
          backgroundColor: .clear)
        viewModel: .init(day: day))
    }
```

Similar item model provider functions are available to customize the views used for month headers, day-of-the-week items, and more.

If you build and run your app, it should now look like this:

![Custom Day Views](Docs/Images/tutorial2.png)

#### Adjusting layout metrics
We can also use `CalendarViewContent` to adjust layout metrics. We can improve the layout of our current `CalendarView` by adding some additional spacing between individual days and months:
```swift
  return CalendarViewContent(...)
    .withDayItemModelProvider { ... }

    .withInterMonthSpacing(24)
    .withVerticalDayMargin(8)
    .withHorizontalDayMargin(8)
```

Just like when we configured a custom day view via the day item provider, changes to layout metrics are also done through `CalendarViewContent`. `withInterMonthSpacing(_:)`, `withVerticalDayMargin(_:)`, and `withHorizontalDayMargin(_:)` each return a mutated `CalendarViewContent` with the corresponding layout metric value updated, enabling you to chain function calls together to produce a final content instance.

After building and running your app, you should see a much less cramped layout:

![Custom Layout Metrics](Docs/Images/tutorial3.png)

#### Adding a day range indicator
Day range indicators are useful for date pickers that need to highlight not just individual days, but ranges of days. `HorizonCalendar` offers an API to do exactly this via the `CalendarViewContent` function `withDayRangeItemModelProvider(for:_:)`. Similar to what we did for our custom day item model provider, for day ranges, we need to provide a `CalendarItemModel` for each day range we want to highlight.

First, we need to create a `ClosedRange<Date>` that represents the day range for which we'd like to provide a `CalendarItemModel`. The `Date`s in our range will be interpreted as `Day`s using the `Calendar` instance with which we initialized our `CalendarViewContent`.
```swift
  let lowerDate = calendar.date(from: DateComponents(year: 2020, month: 01, day: 20))!
  let upperDate = calendar.date(from: DateComponents(year: 2020, month: 02, day: 07))!
  let dateRangeToHighlight = lowerDate...upperDate
```

Next, we need to invoke the `withDayRangeItemModelProvider(for:_:)` on our `CalendarViewContent`:
```swift
  return CalendarViewContent(...)
    ...
    
    .withDayRangeItemModelProvider(for: [dateRangeToHighlight]) { dayRangeLayoutContext in 
      // Return a `CalendarItemModel` representing the view that highlights the entire day range
    }
```

For each day range derived from the `Set<ClosedRange<Date>>` passed into this function, our day range item model provider closure will be invoked with a context instance that contains all of the information needed for us to render a view to be used to highlight a particular day range. Here is an example implementation of such a view:
```swift
import UIKit

final class DayRangeIndicatorView: UIView {

  private let indicatorColor: UIColor

  init(indicatorColor: UIColor) {
    self.indicatorColor = indicatorColor
    super.init(frame: frame)
    backgroundColor = .clear
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  var framesOfDaysToHighlight = [CGRect]() {
    didSet {
      guard framesOfDaysToHighlight != oldValue else { return }
      setNeedsDisplay()
    }
  }

  override func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(indicatorColor.cgColor)

    // Get frames of day rows in the range
    var dayRowFrames = [CGRect]()
    var currentDayRowMinY: CGFloat?
    for dayFrame in framesOfDaysToHighlight {
      if dayFrame.minY != currentDayRowMinY {
        currentDayRowMinY = dayFrame.minY
        dayRowFrames.append(dayFrame)
      } else {
        let lastIndex = dayRowFrames.count - 1
        dayRowFrames[lastIndex] = dayRowFrames[lastIndex].union(dayFrame)
      }
    }

    // Draw rounded rectangles for each day row
    for dayRowFrame in dayRowFrames {
      let roundedRectanglePath = UIBezierPath(roundedRect: dayRowFrame, cornerRadius: 12)
      context?.addPath(roundedRectanglePath.cgPath)
      context?.fillPath()
    }
  }

}
```

Next, we need a type that conforms to `CalendarItemViewRepresentable` that knows how to create and update instances of `DayRangeIndicatorView`. To make things easy, we can just make our view conform to this protocol:
```swift
import HorizonCalendar

extension DayRangeIndicatorView: CalendarItemViewRepresentable {

  struct InvariantViewProperties: Hashable {
    let indicatorColor = UIColor.blue.withAlphaComponent(0.15)
  }

  struct ViewModel: Equatable {
    let framesOfDaysToHighlight: [CGRect]
  }

  static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> DayRangeIndicatorView
  {
    DayRangeIndicatorView(indicatorColor: invariantViewProperties.indicatorColor)
  }

  static func setViewModel(_ viewModel: ViewModel, on view: DayRangeIndicatorView) {
    view.framesOfDaysToHighlight = viewModel.framesOfDaysToHighlight
  }

}

```

Last, we need to return a `CalendarItemModel` representing our `DayRangeIndicatorView` from the day range item model provider closure:
```swift
  return CalendarViewContent(...)
    ...
    
    .withDayRangeItemModelProvider(for: [dateRangeToHighlight]) { dayRangeLayoutContext in
      CalendarItemModel<DayRangeIndicatorView>(
        invariantViewProperties: .init(indicatorColor: UIColor.blue.withAlphaComponent(0.15)),
        viewModel: .init(framesOfDaysToHighlight: dayRangeLayoutContext.daysAndFrames.map { $0.frame }))
    }
```

If you build and run the app, you should see a day range indicator view that highlights 2020-01-20 to 2020-02-07:

![Day Range Indicator](Docs/Images/tutorial4.png)

#### Adding a tooltip
`HorizonCalendar` provides an API to overlay parts of the calendar with custom views. One use case that this enables is adding tooltips to certain days - a feature that's used in the Airbnb app to inform users when their checkout date must be a certain number of days in the future from their check-in date.

First, we need to decide on the locations of the items that we'd like to overlay with our own custom view. We can overlay a `day` or a `monthHeader` - the two cases available on `CalendarViewContent.OverlaidItemLocation`. Let's overlay the day at 2020-01-15:
```swift
  let dateToOverlay = calendar.date(from: DateComponents(year: 2020, month: 01, day: 15))!
  let overlaidItemLocation: CalendarViewContent.OverlaidItemLocation = .day(containingDate: dateToOverlay) 
```

Like all other customizations, we'll add an overlay by calling a function on our `CalendarViewContent` instance that configures an overlay item model provider closure:
```swift
  return CalendarViewContent(...)
    ...
    
    .withOverlayItemModelProvider(for: [overlaidItemLocation]) { overlayLayoutContext in
      // Return a `CalendarItemModel` representing the view to use as an overlay for the overlaid item location
    }
```

For each overlaid item location in the `Set<CalendarViewContent.OverlaidItemLocation>` passed into this function, our overlay item model provider closure will be invoked with a context instance that contains all of the information needed for us to render a view to be used as an overlay for a particular overlaid item location. Here is an example implementation of a tooltip overlay view:
```swift
import UIKit

final class TooltipView: UIView {

  init(backgroundColor: UIColor, borderColor: UIColor, font: UIFont, textColor: UIColor) {
    super.init(frame: .zero)

    backgroundView.backgroundColor = backgroundColor
    backgroundView.layer.borderColor = borderColor
    addSubview(backgroundView)

    label.font = font
    label.textColor = textColor
    addSubview(label)
  }

  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  var text: String {
    get { label.text ?? "" }
    set { label.text = newValue }
  }

  var frameOfTooltippedItem: CGRect? {
    didSet {
      guard frameOfTooltippedItem != oldValue else { return }
      setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard let frameOfTooltippedItem = frameOfTooltippedItem else { return }

    label.sizeToFit()
    let labelSize = CGSize(
      width: min(label.bounds.size.width, bounds.width),
      height: label.bounds.size.height)

    let backgroundSize = CGSize(width: labelSize.width + 16, height: labelSize.height + 16)

    let proposedFrame = CGRect(
      x: frameOfTooltippedItem.midX - (backgroundSize.width / 2),
      y: frameOfTooltippedItem.minY - backgroundSize.height - 4,
      width: backgroundSize.width,
      height: backgroundSize.height)

    let frame: CGRect
    if proposedFrame.maxX > bounds.width {
      frame = proposedFrame.applying(.init(translationX: bounds.width - proposedFrame.maxX, y: 0))
    } else if proposedFrame.minX < 0 {
      frame = proposedFrame.applying(.init(translationX: -proposedFrame.minX, y: 0))
    } else {
      frame = proposedFrame
    }

    backgroundView.frame = frame
    label.center = backgroundView.center
  }

  // MARK: Private

  private lazy var backgroundView: UIView = {
    let view = UIView()
    view.layer.borderWidth = 1
    view.layer.cornerRadius = 6
    view.layer.shadowColor = UIColor.black.cgColor
    view.layer.shadowOpacity = 0.8
    view.layer.shadowOffset = .zero
    view.layer.shadowRadius = 8
    return view
  }()

  private lazy var label: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.lineBreakMode = .byTruncatingTail
    return label
  }()

}
```

Next, we need a type that conforms to `CalendarItemViewRepresentable` that knows how to create and update instances of `TooltipView`. To make things easy, we can just make our view conform to this protocol:
```swift
import HorizonCalendar

extension TooltipView: CalendarItemViewRepresentable {

  struct InvariantViewProperties: Hashable {
    let backgroundColor: UIColor
    let borderColor: UIColor
    let font: UIFont
    let textColor: UIColor
  }

  struct ViewModel: Equatable {
    let frameOfTooltippedItem: CGRect?
    let text: String
  }

  static func makeView(
    withInvariantViewProperties invariantViewProperties: InvariantViewProperties)
    -> TooltipView
  {
  TooltipView(
    borderColor: invariantViewProperties.borderColor, 
    font: invariantViewProperties.font, 
    textColor: invariantViewProperties.textColor)
  }

  static func setViewModel(_ viewModel: ViewModel, on view: TooltipView) {
    view.frameOfTooltippedItem = viewModel.frameOfTooltippedItem
    view.text = viewModel.text
  }

}
```

Last, we need to return a `CalendarItemModel` representing our `TooltipView` from the overlay item model provider closure:
```swift
  return CalendarViewContent(...)
    ...
    
    .withOverlayItemModelProvider(for: [overlaidItemLocation]) { overlayLayoutContext in
      CalendarItemModel<TooltipView>(
        invariantViewProperties: .init(
          backgroundColor: .white, 
          borderColor: .black, 
          font: UIFont.systemFont(ofSize: 16), 
          textColor: .black),
        viewModel: .init(
          frameOfTooltippedItem: overlayLayoutContext.overlaidItemFrame, 
          text: "Dr. Martin Luther King Jr.'s Birthday"))
    }
```

If you build and run the app, you should see a tooltip view hovering above 2020-01-15:

![Tooltip View](Docs/Images/tutorial5.png)


### Responding to day selection
If you're building a date picker, you'll most likely need to respond to the user tapping on days in the calendar. To do this, provide a day selection handler closure via `CalendarView`'s `daySelectionHandler`:
```swift
calendarView.daySelectionHandler = { [weak self] day in
  self?.selectedDay = day
}
```

```swift
private var selectedDay: Day?
```

The day selection handler closure is invoked whenever a day in the calendar is selected. You're provided with a `Day` instance for the day that was selected. If we want to highlight the selected day once its been tapped, we'll need to create a new `CalendarViewContent` with a day calendar item model that looks different for the selected day:
```swift
  let selectedDay = self.selectedDay

  return CalendarViewContent(...)

    .withDayItemModelProvider { day in
      var invariantViewProperties = DayLabel.InvariantViewProperties(
        font: UIFont.systemFont(ofSize: 18), 
        textColor: .darkGray,
        backgroundColor: .clear)

      if day == selectedDay {
        invariantViewProperties.textColor = .white
        invariantViewProperties.backgroundColor = .blue
      }
      
      return CalendarItemModel<DayLabel>(
        invariantViewProperties: invariantViewProperties,
        viewModel: .init(day: day))
  }
```

Last, we'll change our day selection handler so that it not only stores the selected day, but also sets an updated content instance on `calendarView`:
```swift
calendarView.daySelectionHandler = { [weak self] day in
  guard let self = self else { return }
  
  self.selectedDay = day
  
  let newContent = self.makeContent()
  self.calendarView.setContent(newContent)
}
```

After building and running the app, tapping days should cause them to turn blue:

![Day Selection](Docs/Images/tutorial6.png)

## Technical Details
If you'd like to learn about how `HorizonCalendar` was implemented, check out the [Technical Details](Docs/TECHNICAL_DETAILS.md) document. It provides an overview of `HorizonCalendar`'s architecture, along with information about why it's not implemented using `UICollectionView`. 

## Contributions
`HorizonCalendar` welcomes fixes, improvements, and feature additions. If you'd like to contribute, open a pull request with a detailed description of your changes. 

As a rule of thumb, if you're proposing an API-breaking change or a change to existing functionality, consider proposing it by opening an issue, rather than a pull request; we'll use the issue as a public forum for discussing whether the proposal makes sense or not. See [CONTRIBUTING](Docs/CONTRIBUTING.md) for more details.

## Authors
Bryan Keller
- https://github.com/bryankeller
- https://twitter.com/BKyourway19

## Maintainers
Bryan Keller
- https://github.com/bryankeller
- https://twitter.com/BKyourway19

Bryn Bodayle
- https://github.com/brynbodayle
- https://twitter.com/brynbodayle

If you or your company has found `HorizonCalendar` to be useful, let us know!

## License

`HorizonCalendar` is released under the Apache License 2.0. See [LICENSE](LICENSE) for details.
