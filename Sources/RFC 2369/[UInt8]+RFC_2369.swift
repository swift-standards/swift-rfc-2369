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

import INCITS_4_1986

// MARK: - List.Header Serialization

extension [UInt8] {
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
    public init(_ header: RFC_2369.List.Header) {
        self = []

        // List-Help
        if let help = header.help {
            append(contentsOf: "List-Help".utf8)
            append(.ascii.colon)
            append(.ascii.space)
            append(.ascii.lessThanSign)
            append(contentsOf: help.value.utf8)
            append(.ascii.greaterThanSign)
            append(.ascii.cr)
            append(.ascii.lf)
        }

        // List-Unsubscribe
        if let unsubscribe = header.unsubscribe, !unsubscribe.isEmpty {
            append(contentsOf: "List-Unsubscribe".utf8)
            append(.ascii.colon)
            append(.ascii.space)
            for (index, iri) in unsubscribe.enumerated() {
                if index > 0 {
                    append(.ascii.comma)
                    append(.ascii.space)
                }
                append(.ascii.lessThanSign)
                append(contentsOf: iri.value.utf8)
                append(.ascii.greaterThanSign)
            }
            append(.ascii.cr)
            append(.ascii.lf)
        }

        // List-Subscribe
        if let subscribe = header.subscribe, !subscribe.isEmpty {
            append(contentsOf: "List-Subscribe".utf8)
            append(.ascii.colon)
            append(.ascii.space)
            for (index, iri) in subscribe.enumerated() {
                if index > 0 {
                    append(.ascii.comma)
                    append(.ascii.space)
                }
                append(.ascii.lessThanSign)
                append(contentsOf: iri.value.utf8)
                append(.ascii.greaterThanSign)
            }
            append(.ascii.cr)
            append(.ascii.lf)
        }

        // List-Post
        if let post = header.post {
            append(contentsOf: "List-Post".utf8)
            append(.ascii.colon)
            append(.ascii.space)
            append(contentsOf: [UInt8](post))
            append(.ascii.cr)
            append(.ascii.lf)
        }

        // List-Owner
        if let owner = header.owner, !owner.isEmpty {
            append(contentsOf: "List-Owner".utf8)
            append(.ascii.colon)
            append(.ascii.space)
            for (index, iri) in owner.enumerated() {
                if index > 0 {
                    append(.ascii.comma)
                    append(.ascii.space)
                }
                append(.ascii.lessThanSign)
                append(contentsOf: iri.value.utf8)
                append(.ascii.greaterThanSign)
            }
            append(.ascii.cr)
            append(.ascii.lf)
        }

        // List-Archive
        if let archive = header.archive {
            append(contentsOf: "List-Archive".utf8)
            append(.ascii.colon)
            append(.ascii.space)
            append(.ascii.lessThanSign)
            append(contentsOf: archive.value.utf8)
            append(.ascii.greaterThanSign)
            append(.ascii.cr)
            append(.ascii.lf)
        }
    }
}

// MARK: - List.Post Serialization

extension [UInt8] {
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
    public init(_ post: RFC_2369.List.Post) {
        switch post {
        case .noPosting:
            self = [.ascii.N, .ascii.O]

        case .uris(let iris):
            self = []
            for (index, iri) in iris.enumerated() {
                if index > 0 {
                    append(.ascii.comma)
                    append(.ascii.space)
                }
                append(.ascii.lessThanSign)
                append(contentsOf: iri.value.utf8)
                append(.ascii.greaterThanSign)
            }
        }
    }
}
