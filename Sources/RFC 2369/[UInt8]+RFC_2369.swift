// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-rfc-2369 open source project
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

// MARK: - List.Header Serialization

public extension [UInt8] {
    /// Creates ASCII bytes from RFC 2369 List.Header
    ///
    /// Serializes the list headers as RFC 5322 header lines per RFC 2369 Section 2:
    ///
    /// > The contents of the list header fields mostly consist of angle-bracket
    /// > ('<', '>') enclosed URLs, with internal whitespace being ignored.
    /// > Multiple URLs in a single header field MUST be separated by commas.
    ///
    /// ## Category Theory
    ///
    /// Canonical serialization (natural transformation):
    /// - **Domain**: RFC_2369.List.Header (structured data)
    /// - **Codomain**: [UInt8] (ASCII bytes)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let header = RFC_2369.List.Header(
    ///     help: try RFC_3987.IRI("https://example.com/help")
    /// )
    /// let bytes = [UInt8](header)
    /// // bytes == "List-Help: <https://example.com/help>\r\n" as ASCII
    /// ```
    ///
    /// - Parameter header: The list header to serialize
    init(_ header: RFC_2369.List.Header) {
        self = []

        let crlf: [UInt8] = [0x0D, 0x0A]  // CR LF
        let colonSpace: [UInt8] = [0x3A, 0x20]  // ": "
        let lessThan: UInt8 = 0x3C  // <
        let greaterThan: UInt8 = 0x3E  // >
        let comma: UInt8 = 0x2C  // ,
        let space: UInt8 = 0x20  // SP

        // List-Help
        if let help = header.help {
            append(contentsOf: Array("List-Help".utf8))
            append(contentsOf: colonSpace)
            append(lessThan)
            append(contentsOf: Array(help.value.utf8))
            append(greaterThan)
            append(contentsOf: crlf)
        }

        // List-Unsubscribe
        if let unsubscribe = header.unsubscribe, !unsubscribe.isEmpty {
            append(contentsOf: Array("List-Unsubscribe".utf8))
            append(contentsOf: colonSpace)
            for (index, iri) in unsubscribe.enumerated() {
                if index > 0 {
                    append(comma)
                    append(space)
                }
                append(lessThan)
                append(contentsOf: Array(iri.value.utf8))
                append(greaterThan)
            }
            append(contentsOf: crlf)
        }

        // List-Subscribe
        if let subscribe = header.subscribe, !subscribe.isEmpty {
            append(contentsOf: Array("List-Subscribe".utf8))
            append(contentsOf: colonSpace)
            for (index, iri) in subscribe.enumerated() {
                if index > 0 {
                    append(comma)
                    append(space)
                }
                append(lessThan)
                append(contentsOf: Array(iri.value.utf8))
                append(greaterThan)
            }
            append(contentsOf: crlf)
        }

        // List-Post
        if let post = header.post {
            append(contentsOf: Array("List-Post".utf8))
            append(contentsOf: colonSpace)
            append(contentsOf: [UInt8](post))
            append(contentsOf: crlf)
        }

        // List-Owner
        if let owner = header.owner, !owner.isEmpty {
            append(contentsOf: Array("List-Owner".utf8))
            append(contentsOf: colonSpace)
            for (index, iri) in owner.enumerated() {
                if index > 0 {
                    append(comma)
                    append(space)
                }
                append(lessThan)
                append(contentsOf: Array(iri.value.utf8))
                append(greaterThan)
            }
            append(contentsOf: crlf)
        }

        // List-Archive
        if let archive = header.archive {
            append(contentsOf: Array("List-Archive".utf8))
            append(contentsOf: colonSpace)
            append(lessThan)
            append(contentsOf: Array(archive.value.utf8))
            append(greaterThan)
            append(contentsOf: crlf)
        }
    }
}

// MARK: - List.Post Serialization

public extension [UInt8] {
    /// Creates ASCII bytes from RFC 2369 List.Post value
    ///
    /// Per RFC 2369 Section 3.4:
    /// - `.noPosting` renders as `NO`
    /// - `.uris(...)` renders as angle-bracketed, comma-separated URIs
    ///
    /// ## Category Theory
    ///
    /// Canonical serialization (natural transformation):
    /// - **Domain**: RFC_2369.List.Post (structured data)
    /// - **Codomain**: [UInt8] (ASCII bytes)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let post = RFC_2369.List.Post.noPosting
    /// let bytes = [UInt8](post)  // [0x4E, 0x4F] == "NO"
    ///
    /// let postURIs = RFC_2369.List.Post.uris([iri])
    /// let bytes2 = [UInt8](postURIs)  // "<mailto:list@example.com>"
    /// ```
    ///
    /// - Parameter post: The post value to serialize
    init(_ post: RFC_2369.List.Post) {
        let lessThan: UInt8 = 0x3C  // <
        let greaterThan: UInt8 = 0x3E  // >
        let comma: UInt8 = 0x2C  // ,
        let space: UInt8 = 0x20  // SP

        switch post {
        case .noPosting:
            self = Array("NO".utf8)

        case .uris(let iris):
            self = []
            for (index, iri) in iris.enumerated() {
                if index > 0 {
                    append(comma)
                    append(space)
                }
                append(lessThan)
                append(contentsOf: Array(iri.value.utf8))
                append(greaterThan)
            }
        }
    }
}
