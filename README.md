# TCAGithub

This is a successor project for the original [RxGithub](https://github.com/oronbz/RxGithub) using SwiftUI and [The Composable Architecture (TCA)](https://github.com/pointfreeco/swift-composable-architecture) using its companion [Dependencies](https://github.com/pointfreeco/swift-dependencies) package for dependency injection.

## Requirements

- Xcode 14.2 or later
- [GitHub](https://github.com/settings/tokens) personal access token

## Setup

1. Download the source code or clone the repository.
3. Get a free personal access token from [GitHub](https://github.com/settings/tokens).
4. Create a swift file named `Key.swift` with the following content in the `TCAGithub` folder in the project, The string `"TOKEN"` should be replaced with your own personal access token:

**Key.swift**
```Swift
import Foundation

enum Key {
    static var github: String {
        "TOKEN"
    }
}
```

## TODO - Workshop video sessions (Hebrew)