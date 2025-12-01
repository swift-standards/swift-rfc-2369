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

public import INCITS_4_1986

extension RFC_2369.List {
    /// Complete set of list management headers as defined in RFC 2369
    ///
    /// Per RFC 2369, these headers provide automated mail list management capabilities.
    /// Each header contains one or more IRIs (typically HTTP(S) or mailto) that email
    /// clients can use to perform list operations.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let headers = try RFC_2369.List.Header(
    ///     ascii: "List-Help: <https://example.com/help>\r\nList-Post: NO\r\n".utf8
    /// )
    /// ```
    ///
    /// ## RFC 2369 Section 2: Implementation Notes
    ///
    /// > The mailing list header fields are subject to the encoding and character
    /// > restrictions for mail headers as described in [RFC 822].
    /// >
    /// > The contents of the list header fields mostly consist of angle-bracket
    /// > ('<', '>') enclosed URLs, with internal whitespace being ignored.
    /// > Multiple URLs in a single header field MUST be separated by commas.
    public struct Header: Hashable, Sendable, Codable {
        /// List-Help: URI pointing to list help information
        public let help: RFC_3987.IRI?

        /// List-Unsubscribe: One or more URIs for unsubscribing
        public let unsubscribe: [RFC_3987.IRI]?

        /// List-Subscribe: One or more URIs for subscribing
        public let subscribe: [RFC_3987.IRI]?

        /// List-Post: URI(s) for posting to the list, or .noPosting for announcement lists
        public let post: Post?

        /// List-Owner: One or more URIs for contacting the list owner
        public let owner: [RFC_3987.IRI]?

        /// List-Archive: URI pointing to the list archive
        public let archive: RFC_3987.IRI?

        /// Creates a header WITHOUT validation
        init(
            __unchecked: Void,
            help: RFC_3987.IRI?,
            unsubscribe: [RFC_3987.IRI]?,
            subscribe: [RFC_3987.IRI]?,
            post: Post?,
            owner: [RFC_3987.IRI]?,
            archive: RFC_3987.IRI?
        ) {
            self.help = help
            self.unsubscribe = unsubscribe
            self.subscribe = subscribe
            self.post = post
            self.owner = owner
            self.archive = archive
        }

        /// Creates a new set of list headers
        public init(
            help: RFC_3987.IRI? = nil,
            unsubscribe: [RFC_3987.IRI]? = nil,
            subscribe: [RFC_3987.IRI]? = nil,
            post: Post? = nil,
            owner: [RFC_3987.IRI]? = nil,
            archive: RFC_3987.IRI? = nil
        ) {
            self.init(
                __unchecked: (),
                help: help,
                unsubscribe: unsubscribe,
                subscribe: subscribe,
                post: post,
                owner: owner,
                archive: archive
            )
        }
    }
}

// MARK: - UInt8.ASCII.Serializable

extension RFC_2369.List.Header: UInt8.ASCII.Serializable {
//    public static func serialize: @Sendable (Self) -> [UInt8] = [UInt8].init
    static public func serialize<Buffer>(
        ascii header: RFC_2369.List.Header,
        into buffer: inout Buffer
    ) where Buffer : RangeReplaceableCollection, Buffer.Element == UInt8 {
        // List-Help
        if let help = header.help {
            buffer.append(contentsOf: "List-Help".utf8)
            buffer.append(.ascii.colon)
            buffer.append(.ascii.space)
            buffer.append(.ascii.lessThanSign)
            buffer.append(contentsOf: help.value.utf8)
            buffer.append(.ascii.greaterThanSign)
            buffer.append(.ascii.cr)
            buffer.append(.ascii.lf)
        }

        // List-Unsubscribe
        if let unsubscribe = header.unsubscribe, !unsubscribe.isEmpty {
            buffer.append(contentsOf: "List-Unsubscribe".utf8)
            buffer.append(.ascii.colon)
            buffer.append(.ascii.space)
            for (index, iri) in unsubscribe.enumerated() {
                if index > 0 {
                    buffer.append(.ascii.comma)
                    buffer.append(.ascii.space)
                }
                buffer.append(.ascii.lessThanSign)
                buffer.append(contentsOf: iri.value.utf8)
                buffer.append(.ascii.greaterThanSign)
            }
            buffer.append(.ascii.cr)
            buffer.append(.ascii.lf)
        }

        // List-Subscribe
        if let subscribe = header.subscribe, !subscribe.isEmpty {
            buffer.append(contentsOf: "List-Subscribe".utf8)
            buffer.append(.ascii.colon)
            buffer.append(.ascii.space)
            for (index, iri) in subscribe.enumerated() {
                if index > 0 {
                    buffer.append(.ascii.comma)
                    buffer.append(.ascii.space)
                }
                buffer.append(.ascii.lessThanSign)
                buffer.append(contentsOf: iri.value.utf8)
                buffer.append(.ascii.greaterThanSign)
            }
            buffer.append(.ascii.cr)
            buffer.append(.ascii.lf)
        }

        // List-Post
        if let post = header.post {
            buffer.append(contentsOf: "List-Post".utf8)
            buffer.append(.ascii.colon)
            buffer.append(.ascii.space)
            buffer.append(contentsOf: [UInt8](post))
            buffer.append(.ascii.cr)
            buffer.append(.ascii.lf)
        }

        // List-Owner
        if let owner = header.owner, !owner.isEmpty {
            buffer.append(contentsOf: "List-Owner".utf8)
            buffer.append(.ascii.colon)
            buffer.append(.ascii.space)
            for (index, iri) in owner.enumerated() {
                if index > 0 {
                    buffer.append(.ascii.comma)
                    buffer.append(.ascii.space)
                }
                buffer.append(.ascii.lessThanSign)
                buffer.append(contentsOf: iri.value.utf8)
                buffer.append(.ascii.greaterThanSign)
            }
            buffer.append(.ascii.cr)
            buffer.append(.ascii.lf)
        }

        // List-Archive
        if let archive = header.archive {
            buffer.append(contentsOf: "List-Archive".utf8)
            buffer.append(.ascii.colon)
            buffer.append(.ascii.space)
            buffer.append(.ascii.lessThanSign)
            buffer.append(contentsOf: archive.value.utf8)
            buffer.append(.ascii.greaterThanSign)
            buffer.append(.ascii.cr)
            buffer.append(.ascii.lf)
        }
    }

    /// Parses list headers from ASCII bytes (AUTHORITATIVE IMPLEMENTATION)
    ///
    /// ## RFC 2369 Section 2
    ///
    /// > The contents of the list header fields mostly consist of angle-bracket
    /// > ('<', '>') enclosed URLs, with internal whitespace being ignored.
    ///
    /// ## Category Theory
    ///
    /// Parsing transformation:
    /// - **Domain**: [UInt8] (ASCII bytes)
    /// - **Codomain**: RFC_2369.List.Header (structured data)
    ///
    /// - Parameter bytes: The header as ASCII bytes
    /// - Throws: `Error` if parsing fails
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void = ()) throws(Error)
    where Bytes.Element == UInt8 {
        let byteArray = Array(bytes)

        // Helper to trim whitespace
        func trimWhitespace(_ arr: [UInt8]) -> [UInt8] {
            var result = arr
            while !result.isEmpty && (result.first == .ascii.space || result.first == .ascii.htab) {
                result.removeFirst()
            }
            while !result.isEmpty && (result.last == .ascii.space || result.last == .ascii.htab) {
                result.removeLast()
            }
            return result
        }

        // Helper to extract IRIs from angle-bracketed, comma-separated list
        func parseIRIs(_ value: [UInt8]) -> [RFC_3987.IRI] {
            var iris: [RFC_3987.IRI] = []
            var current: [UInt8] = []
            var inBrackets = false

            for byte in value {
                if byte == .ascii.lessThanSign {
                    inBrackets = true
                    current = []
                } else if byte == .ascii.greaterThanSign {
                    inBrackets = false
                    if !current.isEmpty {
                        let iriString = String(decoding: current, as: UTF8.self)
                        if let iri = try? RFC_3987.IRI(iriString) {
                            iris.append(iri)
                        }
                    }
                } else if inBrackets {
                    current.append(byte)
                }
            }
            return iris
        }

        // Split into lines
        var lines: [[UInt8]] = []
        var currentLine: [UInt8] = []
        for byte in byteArray {
            if byte == .ascii.cr || byte == .ascii.lf {
                if !currentLine.isEmpty {
                    lines.append(currentLine)
                    currentLine = []
                }
            } else {
                currentLine.append(byte)
            }
        }
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }

        var help: RFC_3987.IRI?
        var unsubscribe: [RFC_3987.IRI]?
        var subscribe: [RFC_3987.IRI]?
        var post: RFC_2369.List.Post?
        var owner: [RFC_3987.IRI]?
        var archive: RFC_3987.IRI?

        for line in lines {
            guard let colonIndex = line.firstIndex(of: .ascii.colon) else { continue }

            let fieldNameBytes = trimWhitespace(Array(line[..<colonIndex]))
            let fieldValueBytes = trimWhitespace(Array(line[(colonIndex + 1)...]))

            let fieldName = String(decoding: fieldNameBytes, as: UTF8.self).lowercased()

            switch fieldName {
            case "list-help":
                let iris = parseIRIs(fieldValueBytes)
                help = iris.first

            case "list-unsubscribe":
                let iris = parseIRIs(fieldValueBytes)
                unsubscribe = iris.isEmpty ? nil : iris

            case "list-subscribe":
                let iris = parseIRIs(fieldValueBytes)
                subscribe = iris.isEmpty ? nil : iris

            case "list-post":
                // Check for "NO" (case-insensitive)
                let trimmed = trimWhitespace(fieldValueBytes)
                let valueString = String(decoding: trimmed, as: UTF8.self).uppercased()
                if valueString == "NO" {
                    post = .noPosting
                } else {
                    let iris = parseIRIs(fieldValueBytes)
                    post = iris.isEmpty ? nil : .uris(iris)
                }

            case "list-owner":
                let iris = parseIRIs(fieldValueBytes)
                owner = iris.isEmpty ? nil : iris

            case "list-archive":
                let iris = parseIRIs(fieldValueBytes)
                archive = iris.first

            default:
                break
            }
        }

        self.init(
            __unchecked: (),
            help: help,
            unsubscribe: unsubscribe,
            subscribe: subscribe,
            post: post,
            owner: owner,
            archive: archive
        )
    }
}

// MARK: - Protocol Conformances

extension RFC_2369.List.Header: UInt8.ASCII.RawRepresentable {
    public typealias RawValue = String
}

extension RFC_2369.List.Header: CustomStringConvertible {
    public var description: String {
        String(self)
    }
}

// MARK: - Email Header Rendering

extension [String: String] {
    /// Creates email header dictionary from RFC 2369 list headers
    ///
    /// - Parameter listHeader: The RFC 2369 list header to render
    public init(listHeader: RFC_2369.List.Header) {
        var headers: [String: String] = [:]

        if let help = listHeader.help {
            headers["List-Help"] = "<\(help.value)>"
        }

        if let unsubscribe = listHeader.unsubscribe, !unsubscribe.isEmpty {
            headers["List-Unsubscribe"] =
                unsubscribe
                .map { "<\($0.value)>" }
                .joined(separator: ", ")
        }

        if let subscribe = listHeader.subscribe, !subscribe.isEmpty {
            headers["List-Subscribe"] =
                subscribe
                .map { "<\($0.value)>" }
                .joined(separator: ", ")
        }

        if let post = listHeader.post {
            headers["List-Post"] = post.description
        }

        if let owner = listHeader.owner, !owner.isEmpty {
            headers["List-Owner"] =
                owner
                .map { "<\($0.value)>" }
                .joined(separator: ", ")
        }

        if let archive = listHeader.archive {
            headers["List-Archive"] = "<\(archive.value)>"
        }

        self = headers
    }
}
