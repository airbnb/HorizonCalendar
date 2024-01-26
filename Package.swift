// swift-tools-version: 5.8.1
import PackageDescription

let package = Package(
  name: "HorizonCalendar",
  platforms: [
    .iOS(.v12),
  ],
  products: [
    .library(name: "HorizonCalendar", targets: ["HorizonCalendar"]),
  ],
  dependencies: [
    .package(url: "https://github.com/airbnb/swift", .upToNextMajor(from: "1.0.1")),
  ],
  targets: [
    .target(
      name: "HorizonCalendar",
      path: "Sources"),
    .testTarget(
      name: "HorizonCalendarTests",
      dependencies: ["HorizonCalendar"],
      path: "Tests"),
  ],
  swiftLanguageVersions: [.v5])
