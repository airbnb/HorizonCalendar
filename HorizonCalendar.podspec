Pod::Spec.new do |spec|
  spec.name = "HorizonCalendar"
  spec.version = "2.0.0"
  spec.license = "Apache License, Version 2.0"
  spec.summary = "A declarative, performant, calendar UI component that supports use cases ranging from simple date pickers to fully-featured calendar apps."

  spec.description = <<-DESC
`HorizonCalendar` is an interactive calendar component for iOS (compatible with UIKit and SwiftUI). Its declarative API makes updating the calendar straightforward, while also providing many customization points to support a diverse set of designs and use cases.

Features:

- Supports all calendars from `Foundation.Calendar` (Gregorian, Japanese, Hebrew, etc.)
- Display months in a vertically-scrolling or horizontally-scrolling layout
- Declarative API that encourages unidirectional data flow for updating the content of the calendar
- A custom layout system that enables virtually infinite date ranges without increasing memory usage
- Animated content updates
- Pagination for horizontally-scrolling calendars
- Self-sizing month headers
- Specify custom views (`UIView` or SwiftUI `View`) for individual days, month headers, and days of the week
- Specify custom views (`UIView` or SwiftUI `View`) to highlight date ranges
- Specify custom views (`UIView` or SwiftUI `View`) to overlay parts of the calendar, enabling features like tooltips
- Specify custom views (`UIView` or SwiftUI `View`) for month background decorations (colors, grids, etc.)
- Specify custom views (`UIView` or SwiftUI `View`) for day background decorations (colors, patterns, etc.)
- A day selection handler to monitor when a day is tapped
- A multi-day selection handler to monitor when multiple days are selected via a drag gesture
- Customizable layout metrics
- Pin the days-of-the-week row to the top
- Show partial boundary months (exactly 2020-03-14 to 2020-04-20, for example)
- Scroll to arbitrary dates and months, with or without animation
- Robust accessibility support
- Inset the content without affecting the scrollable region using layout margins
- Separator below the days-of-the-week row
- Right-to-left layout support
                   DESC
  spec.source = { :git => "https://github.com/airbnb/HorizonCalendar.git", :tag => "v#{spec.version}" }
  spec.homepage = "https://github.com/airbnb/HorizonCalendar"
  spec.authors = { "Bryan Keller" => "kellerbryan19@gmail.com" }
  spec.social_media_url = "https://twitter.com/BKYourWay19"
  spec.swift_version = "5.9"
  spec.ios.deployment_target = '12.0'
  spec.source_files = "Sources/**/*.{swift,h}"
end
