# Changelog
All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased](https://github.com/airbnb/HorizonCalendar/compare/v2.0.0...HEAD)

### Added
- Added support for disabling touch handling on SwiftUI views via the `allowsHitTesting` modifier
- Added SwiftUI documentation to the README.md
- Added properties to `CalendarViewProxy` for getting the `visibleMonthRange` and `visibleDayRange` 

### Fixed
- Fixed an issue that could cause accessibility focus to shift unexpectedly
- Fixed a screen-pixel alignment issue
- Fixed a performance issue caused by month headers recalculating their size too often
- Fixed a performance issue caused by the item models for day ranges and month backgrounds not being cached

### Changed
- Rewrote accessibility code to avoid posting notifications, which causes poor Voice Over performance and odd focus bugs
- Rewrote `ItemViewReuseManager` to perform fewer set operations, improving CPU usage by ~15% when scrolling quickly on an iPhone XR
- Updated how we embed SwiftUI views to improve scroll performance by ~35% when scrolling quickly

## [v2.0.0](https://github.com/airbnb/HorizonCalendar/compare/v1.16.0...v2.0.0) - 2023-12-19

### Added
- Added `MonthsLayout.vertical` and `MonthsLayout.horizontal` as more concise alternatives to `MonthsLayout.vertical(options: .init())` and `MonthsLayout.horizontal(options: .init())`, respectively
- Added `CalendarViewRepresentable`, enabling developers to use `CalendarView` in a SwiftUI view hierarchy
- Added a `multiDaySelectionDragHandler`, enabling developers to implement multiple-day-selection via a drag gesture (similar to multi-select in the iOS Photos app)
- Added the ability to change the aspect ratio of individual day-of-the-week items
- Added support for self-sizing month headers
- Added a new `setContent(_:animated:)` function, enabling developers to perform animated content updates
- Added Swift format integration to enforce consistent code style

### Fixed
- Fixed an issue that could cause the calendar to programmatically scroll to a month or day to which it had previously scrolled
- Fixed Storyboard support by removing the `fatalError` in `init?(coder: NSCoder)`
- Fixed an issue that could cause the calendar to layout unnecessarily due to a trait collection change notification
- Fixed an issue that could cause off-screen items to appear or disappear instantly, rather than animating in or out during animated content changes
- Fixed an issue that caused a SwiftUI view being used as a calendar item to not receive calls to `onAppear`
- Fixed an accessibility issue that prevented scrolling callbacks from firing when scrolling via voiceover.
- Fixed an issue that caused Voice Over users to be unable to reliably navigate by heading

### Changed
- Removed all deprecated code, simplifying the public API in preparation for a 2.0 release
- Renamed `viewModel` to `content`, since it's a less-overloaded term
- Changed `monthDayInsets` to take `NSDirectionalEdgeInsets`, rather than `UIEdgeInsets`
- Un-nested some types to make them fit better with an upcoming SwiftUI API
- Updated the default `HorizontalMonthLayoutOptions` to use a `restingPosition` of `.atLeadingEdgeOfEachMonth`, which is probably what most people want
- Updated more publicly-exposed types conform to `Hashable`, because why not - maybe API consumers want to stick things in a `Set` or `Dictionary`.
- Allowed `CalendarItemViewRepresentable` to have no `Content` type if the conforming view does not depend on any variable data
- Changed `ItemView` to determine user interaction capabilities from its content view's `hitTest` / `pointInside` functions
- Updated content-change animations so that the same scroll offset is maintained throughout the animation
- Changed the Swift version needed to use HorizonCalendar to 5.8
- Simplified accessibility (Voice Over) support so that it works consistently for calendars containing UIKit and SwiftUI views
- Renamed `Day` to `DayComponents` and `Month` to `MonthComponents` to clarify their intended use


## [v1.16.0](https://github.com/airbnb/HorizonCalendar/compare/v1.15.0...v1.16.0) - 2023-01-30

### Added
- Added support for month backgrounds, enabling things like grid lines and colored backgrounds for months
- Added a `dayRange` property to `CalendarViewContent.DayRangeLayoutContext`
- Added support for day backgrounds, enabling developers to add visual decoration behind individual days. These decoration views also appear behind any day range indicators, making it possible to have a day range indicator appear between the day's number and any background decoration.
- Added `MonthGridBackgroundView`, a view that can be used with the `monthBackgroundItemProvider` to add grid lines between the days in a month

### Fixed
- Fixed an issue that caused an in-flight programmatic scroll to be cancelled if `setContent` was called
- Fixed an issue that caused the pinned days-of-the-week row separator to appear at the wrong z-position
- Fixed an issue that caused accessibility focus to shift to an unexpected location after some types of content updates occurred

### Changed
- Removed spaces from folder names within the `Sources` folder to reduce the chance of sensitive 🥺 build systems complaining or breaking

## [v1.15.0](https://github.com/airbnb/HorizonCalendar/compare/v1.14.0...v1.15.0) - 2022-12-25

### Added
- Added support for animating content updates by calling forcing layout via `layoutIfNeeded` in a `UIView.animate` closure
- Added a convenience function to create a `CalendarItemModel` from a type conforming to `CalendarItemViewRepresentable`
- Added support for using SwiftUI views in the calendar. `SwiftUIWrapperView` was introduced to enable this functionality, but there is no need to use it directly; instead, use the `calendarItemModel` property on any SwiftUI view, and return it from any of the `CalendarViewContent` item-provider closures.
- Added a SwiftUI example to the example app and README.md
- Added this Changelog doc

### Fixed
- Fixed a visual issue where `UINavigationController`'s navigation bar did not become opaque when the calendar was scrolled, resulting in the calendar's content conflicting with text in the navigation bar

### Changed
- Updated code using `UIScreen.main.scale` (deprecated in iOS 16) to use `traitCollection.displayScale` instead
- Updated README.md and the example app to use the new convenience function for creating `CalendarItemModel`s
- Improved the highlight-state animation for the default `DayView`, improving perceived responsiveness
- Renamed the internal type `VisibleCalendarItem` to `VisibleItem` for brevity
- Switched from relying on `layer.zPosition` to control item view z-axis ordering, to inserting subviews in the correct order of the scroll view's subviews array
- Optimized view reuse code by hiding and unhiding views, rather than adding and removing subviews. This was made possible by the aforementioned z-axis ordering refactor.

## [v1.14.0](https://github.com/airbnb/HorizonCalendar/compare/v1.13.0...v1.14.0) - 2022-08-18

### Added
- Added an option for vertical calendars to scroll to the top when the system status bar is tapped

### Fixed
- Fixed a crash that occurred when programmatically scrolling to an out-of-bounds day
- Fixed an issue that could cause the calendar to recalculate its layout using stale information after setting its content to a new value

### Changed
- Updated README.md to not reference deprecated functions
- Removed an unnecessary layout assertion and replaced it with a warning

## [v1.13.0](https://github.com/airbnb/HorizonCalendar/compare/v1.12.0...v1.13.0) - 2021-12-23

### Changed
- Deprecated `CalendarViewContent` functions that have a "with" prefix, replacing them with equivalent functions that omit the unnecessary prefix

## [v1.12.0](https://github.com/airbnb/HorizonCalendar/compare/v1.11.0...v1.12.0) - 2021-12-22

### Added
- Added the ability to change the aspect ratio of individual days in the calendar, removing the limitation that all days must have square frames

## [v1.11.0](https://github.com/airbnb/HorizonCalendar/compare/v1.10.0...v1.11.0) - 2021-11-09

### Fixed
- Fixed a broken code example in README.md

### Changed
- Updated programmatic scroll code to animate at 120hz on ProMotion displays
- Improved layout logic to enable horizontal calendars to derive their height from their width, layout margins, and content. When using a horizontal calendar with Auto Layout, only position and width constraints are needed; a tightly-bounding height will be set automatically.

## [v1.10.0](https://github.com/airbnb/HorizonCalendar/compare/v1.9.0...v1.10.0) - 2021-09-14

### Added
- Added `DayView`, `DayOfWeekView`, and `MonthHeaderView` - public, configurable views that cover many common use cases

## [v1.9.0](https://github.com/airbnb/HorizonCalendar/compare/v1.8.0...v1.9.0) - 2021-09-04

### Added
- Added a `.pageScrolled` accessibility notification when the calendar scrolls due to an accessibility gesture
- Added a `_didEndDragging` closure that includes a `willDecelerate` parameter. The `didEndDragging` closure has been deprecated.

### Fixed
- Fixed a bug that caused the z-positions of views to be incorrect when snapshotting the `CalendarView`
- Fixed a visual issue that occurred when programmatically scrolling to a day or month and using partial-month-visibility
- Fixed a bug that caused the three-finger-accessibility-scroll gesture to not work
- Fixed a bug that caused the current scroll position to be lost on device rotation or when the layout margins change

### Changed
- Improved the example project to better demonstrate how to implement day selection
- Improved accessibility support the example project
- Deprecated the `didEndDragging` closure in favor of `_didEndDragging`

## [v1.8.0](https://github.com/airbnb/HorizonCalendar/compare/v1.7.0...v1.8.0) - 2021-03-05

### Added
- Added an API to get an accessibility element for a visible date - useful for working with `UIAccessibility.post(notification:argument:)` to programmatically change accessibility focus

### Fixed
- Fixed a visual issue that occurred when programmatically scrolling to a day or month and using non-zero layout margins
- Fixed an issue that could cause layout margins to be set to an incorrect value

## [v1.7.0](https://github.com/airbnb/HorizonCalendar/compare/v1.6.0...v1.7.0) - 2021-01-27

### Added
- Added `HorizontalMonthsLayoutOptions` and `VerticalMonthsLayoutOptions` for configuring horizontal and vertical calendars
- Added pagination support for horizontal calendars

### Fixed
- Fixed a localization issue with the date formatters used by the default month header and day views
- Fixed a layout bug due to inaccurate floating point comparison math
- Fixed a visual issue where reused subviews of the calendar would animate from their old frame to their new frame
- Fixed an incorrect `Hashable` / `Equatable` implementation for the internal `VisibleCalendarItem` type
- Fixed a bug that caused `didEndDecelerating` to be called instead of `didEndDragging`
- Fixed a Mac-Catalyst scrolling bug

### Changed
- Updated the `MonthsLayout` API to be more consistent for both vertical and horizontal calendars
- Deprecated `MonthsLayout.horizontal(monthWidth: CGFloat)` in favor of `MonthsLayout.horizontal(options: HorizontalMonthsLayoutOptions)`
- Updated README.md to use `Calendar.current` rather than `Calendar(identifier: .gregorian)`
- Consolidated some internal layout code
- Simplified internal `UIScrollView` state management to no longer loop the scroll position

## [v1.6.0](https://github.com/airbnb/HorizonCalendar/compare/v1.5.0...v1.6.0) - 2020-11-07

### Changed
- Deprecated the `CalendarViewContent` `withBackgroundColor(_:)` API; developers should use the `UIView` `backgroundColor` property on `CalendarView` directly.

## [v1.5.0](https://github.com/airbnb/HorizonCalendar/compare/v1.4.0...v1.5.0) - 2020-09-20

### Added
- Added support for right-to-left layout when using a right-to-left language like Hebrew and Arabic 

### Fixed
- Fixed a broken code example in README.md
- Fixed CI
- Fixed an issue that caused layout margins to be ignored when programmatically scrolling

### Changed
- Updated README.md to use the new `CalendarItemModel` type, rather than the deprecated `CalendarItem` type
- Removed an artificial limitation that caused all non-day item views to have `isUserInteractionEnabled` set to `false`

## [v1.4.0](https://github.com/airbnb/HorizonCalendar/compare/v1.3.0...v1.4.0) - 2020-08-26

### Added
- Added a new API for creating items in the calendar - `CalendarItemModel` - which simplifies the creation of items while eliminating a class of bugs that were possible due to misconfigured style IDs. `CalendarItemModel` replaces [the now deprecated] `CalendarItem` type. Use types conforming to `CalendarItemViewRepresentable` to create `CalendarItemModel`s. The deprecated `CalendarItem` type will be removed in the v2.0.0 release. 

### Fixed
- Fixed a crash that could occur when updating the calendar's content while a programmatic scroll is happening

### Changed
- Deprecated legacy `CalendarItem` types in favor of the newly added `CalendarItemModel` types

## [v1.3.0](https://github.com/airbnb/HorizonCalendar/compare/v1.2.0...v1.3.0) - 2020-08-05

### Added
- Added the ability to show a configurable separator between the days-of-the-week row and the content below

### Fixed
- Fixed a bug that caused layout margins to be applied twice to month headers
- Fixed a layout issue due to the introduction of layout margin support
- Fixed an overlapping content visual issue with the pinned days-of-the-week row
- Fixed a visual issue that caused month headers to disappear while scrolling a horizontal calendar

## [v1.2.0](https://github.com/airbnb/HorizonCalendar/compare/v1.1.0...v1.2.0) - 2020-06-29

### Added
- Added the ability to inset the calendar using `layoutMargins` and `directionalLayoutMargins`

### Fixed
- Fixed a broken code example in README.md
- Fixed a visual issue that could occur when programmatically scrolling to a day or month
- Fixed a bug with the internal scroll offset calculations

### Changed
- Deprecated publicly-exposed scroll view delegate functions, which were never intended to be part of the public API surface

## [v1.1.0](https://github.com/airbnb/HorizonCalendar/compare/v1.0.0...v1.1.0) - 2020-06-26

### Added
- Added CONTRIBUTING.md
- Added TECHNICAL_DETAILS.md, a  document that outlines the how and why behind HorizonCalendar's architecture
- Added the ability to only show a subset of weeks in a boundary month
- Added support for insetting the calendar's content with `layoutMargins` and `directionalLayoutMargins`

### Fixed
- Fixed CI
- Fixed horizontal calendar demo layout code
- Fixed a layout bug for horizontal calendars
- Fixed a Voice Over behavior when navigating by month heading

### Changed
- Improved documentation
- Improved unit test message
- Improved example project constraint setup code
- Improved the responsiveness of selecting a day with Voice Over

## [v1.0.0](https://github.com/airbnb/HorizonCalendar/compare/a48631fb...v1.0.0) - 2020-06-19

### Added
- Initial release of HorizonCalendar
