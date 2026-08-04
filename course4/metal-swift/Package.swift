// swift-tools-version:5.9
// Swift/Metal lab apps (Modules 0, 2, 3). One executable per lab; `swift build`
// builds them all, `swift run Lab04` runs one. For GPU capture, open this
// folder in Xcode (File > Open) and run from there.
import PackageDescription

let labs = ["Lab04", "Lab21", "Lab22", "Lab23", "Lab24", "Lab25",
            "Lab31", "Lab32", "Lab33", "Lab34"]

let package = Package(
    name: "course4-metal-labs",
    platforms: [.macOS(.v14)],
    targets: labs.map { .executableTarget(name: $0, path: "Sources/\($0)") }
)
