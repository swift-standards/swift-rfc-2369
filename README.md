# swift-rfc-2369

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Swift implementation of RFC 2369: The Use of URLs as Meta-Syntax for Core Mail List Commands

## Overview

This package provides a Swift implementation of list management headers as defined in [RFC 2369](https://www.ietf.org/rfc/rfc2369.txt). These headers enable automated mail list management by providing standardized email headers that clients can use to display subscription management controls.

## Features

- ✅ Complete RFC 2369 header support (List-Help, List-Unsubscribe, List-Subscribe, List-Post, List-Owner, List-Archive)
- ✅ Type-safe header construction
- ✅ RFC-compliant header rendering
- ✅ Support for multiple URIs per header
- ✅ Special "NO" value for announcement-only lists
- ✅ IRI support via RFC 3987
- ✅ Foundation `URL` compatibility
- ✅ Swift 6 strict concurrency support
- ✅ Full `Sendable` conformance

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-rfc-2369", branch: "main")
]
```

## Usage

### Creating List Headers

```swift
import RFC_2369
import RFC_3987

// Create list headers with all fields
let headers = try RFC_2369.List.Header(
    help: try RFC_3987.IRI("https://example.com/help"),
    unsubscribe: [
        try RFC_3987.IRI("https://example.com/unsubscribe"),
        try RFC_3987.IRI("mailto:unsubscribe@example.com")
    ],
    subscribe: [try RFC_3987.IRI("https://example.com/subscribe")],
    post: .uris([try RFC_3987.IRI("mailto:list@example.com")]),
    owner: [try RFC_3987.IRI("mailto:owner@example.com")],
    archive: try RFC_3987.IRI("https://example.com/archive")
)
```

### Using Foundation URLs

```swift
// Foundation URLs work seamlessly via IRI.Representable
let headers = RFC_2369.List.Header(
    help: URL(string: "https://example.com/help")!,
    unsubscribe: [URL(string: "https://example.com/unsubscribe")!]
)
```

### Rendering as Email Headers

```swift
let emailHeaders = [String: String](listHeader: headers)
// [
//     "List-Help": "<https://example.com/help>",
//     "List-Unsubscribe": "<https://example.com/unsubscribe>, <mailto:unsubscribe@example.com>",
//     "List-Subscribe": "<https://example.com/subscribe>",
//     "List-Post": "<mailto:list@example.com>",
//     "List-Owner": "<mailto:owner@example.com>",
//     "List-Archive": "<https://example.com/archive>"
// ]
```

### Announcement-Only Lists

```swift
// For lists that don't accept posts
let headers = RFC_2369.List.Header(
    help: try RFC_3987.IRI("https://example.com/help"),
    post: .noPosting  // Renders as "List-Post: NO"
)
```

## RFC 2369 Compliance

This implementation follows RFC 2369 precisely:

- ✅ Multiple URIs separated by commas
- ✅ URIs enclosed in angle brackets (`<` and `>`)
- ✅ Support for `mailto:` and `http(s):` schemes
- ✅ Special "NO" value for List-Post
- ✅ All six standard list headers

### RFC 2369 Examples

#### Example 1: Basic Email List

From RFC 2369 Section 4.1:

```swift
let headers = try RFC_2369.List.Header(
    help: try RFC_3987.IRI("mailto:list@host.com?subject=help"),
    unsubscribe: [try RFC_3987.IRI("mailto:list@host.com?subject=unsubscribe")],
    subscribe: [try RFC_3987.IRI("mailto:list@host.com?subject=subscribe")],
    post: .uris([try RFC_3987.IRI("mailto:list@host.com")]),
    owner: [try RFC_3987.IRI("mailto:listmom@host.com")]
)
```

#### Example 2: Web-Based List

From RFC 2369 Section 4.2:

```swift
let headers = try RFC_2369.List.Header(
    help: try RFC_3987.IRI("http://www.host.com/list/"),
    unsubscribe: [
        try RFC_3987.IRI("http://www.host.com/list.cgi?cmd=unsub&lst=list"),
        try RFC_3987.IRI("mailto:list-request@host.com?subject=unsubscribe")
    ],
    post: .uris([try RFC_3987.IRI("mailto:list@host.com")])
)
```

#### Example 3: Announcement List

From RFC 2369 Section 4.3:

```swift
let headers = try RFC_2369.List.Header(
    help: try RFC_3987.IRI("mailto:list-info@host.com"),
    post: .noPosting  // "NO (posting not allowed on this list)"
)
```

## Type Overview

### `RFC_2369.List.Header`

Complete set of list management headers. All fields are optional to support various list configurations.

```swift
public struct Header {
    public let help: RFC_3987.IRI?
    public let unsubscribe: [RFC_3987.IRI]?
    public let subscribe: [RFC_3987.IRI]?
    public let post: Post?
    public let owner: [RFC_3987.IRI]?
    public let archive: RFC_3987.IRI?
}
```

### `RFC_2369.List.Post`

Special type for the List-Post header that can be either URIs or "NO":

```swift
public enum Post {
    case uris([RFC_3987.IRI])
    case noPosting  // Renders as "NO"
}
```

## Requirements

- Swift 6.0+
- macOS 14+, iOS 17+, tvOS 17+, watchOS 10+

## Related RFCs

- [RFC 2369](https://www.ietf.org/rfc/rfc2369.txt) - The Use of URLs as Meta-Syntax for Core Mail List Commands
- [RFC 3987](https://www.ietf.org/rfc/rfc3987.txt) - Internationalized Resource Identifiers (IRIs)
- [RFC 8058](https://www.ietf.org/rfc/rfc8058.txt) - Signaling One-Click Functionality for List Email Headers

## Related Packages

- [swift-rfc-3987](https://github.com/swift-standards/swift-rfc-3987) - IRI implementation
- [swift-rfc-8058](https://github.com/swift-standards/swift-rfc-8058) - One-click unsubscribe (companion to RFC 2369)

## License & Contributing

Licensed under Apache 2.0.

Contributions welcome! Please ensure:
- All tests pass
- Code follows existing style
- RFC 2369 compliance maintained
