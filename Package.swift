// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "SCConfiguration",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    .library(name: "SCConfiguration", targets: ["SCConfiguration"])
  ],
  dependencies: [
  ],
  targets: [
    .binaryTarget(
            name: "SCConfiguration",
            url: "https://github.com/team-supercharge/SCConfiguration/releases/download/2.3.0/SCConfiguration.xcframework.zip",
            checksum: "45384dbfac263e66218ce67b0d083ae805ee0b252653ed76b72444423764fb63"
        )        
  ],
  swiftLanguageVersions: [.v5]
)