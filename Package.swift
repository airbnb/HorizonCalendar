// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "HorizonCalendar",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(name: "HorizonCalendar", targets: ["HorizonCalendar"])
    ],
    targets: [
        .target(
            name: "HorizonCalendar",
            path: "Sources"
        ),
        .testTarget(
            name: "HorizonCalendarTests",
            dependencies: ["HorizonCalendar"],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
