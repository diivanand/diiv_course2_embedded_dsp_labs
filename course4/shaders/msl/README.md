MSL sources for the metal-cpp backend (Module 4+): compiled per-lab with
`xcrun -sdk macosx metal` into a `.metallib`, or at runtime during bring-up.
The Swift apps of Modules 0/2/3 keep their `.metal` files inside
`metal-swift/` where Xcode/SwiftPM builds them.
