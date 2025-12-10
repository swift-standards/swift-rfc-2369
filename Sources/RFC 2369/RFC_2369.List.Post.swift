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
    /// Value for the List-Post header as defined in RFC 2369 Section 3.4
    ///
    /// The List-Post header can either contain one or more URIs for posting messages,
    /// or the special value "NO" indicating the list does not accept posts
    /// (announcement-only list).
    ///
    /// ## RFC 2369 Section 3.4: List-Post
    ///
    /// > The List-Post field describes the method for posting to the list.
    /// > This is typically the address of the list, but MAY be a moderator, or MAY be
    /// > unavailable (as indicated by the special value "NO").
    /// >
    /// > Examples:
    /// > ```
    /// > List-Post: <mailto:list@host.com>
    /// > List-Post: <mailto:moderator@host.com> (Postings are Moderated)
    /// > List-Post: <mailto:moderator@host.com?subject=list%20posting>
    /// > List-Post: NO (posting not allowed on this list)
    /// > ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Regular list accepting posts
    /// let post = RFC_2369.List.Post.uris([
    ///     try RFC_3987.IRI("mailto:list@example.com")
    /// ])
    ///
    /// // Announcement-only list
    /// let announcementPost = RFC_2369.List.Post.noPosting
    ///
    /// // Serialize to bytes
    /// let bytes = post.bytes
    ///
    /// // Or render to string
    /// print(String(post))  // "<mailto:list@example.com>"
    /// print(String(announcementPost))  // "NO"
    /// ```
    public enum Post: Hashable, Sendable {
        /// One or more URIs where messages can be posted
        ///
        /// Per RFC 2369 Section 3.4:
        /// > List-Post: <mailto:list@host.com>
        case uris([RFC_3987.IRI])

        /// Special value "NO" indicating posting is not allowed
        ///
        /// Per RFC 2369 Section 3.4:
        /// > List-Post: NO (posting not allowed on this list)
        case noPosting
    }
}

// MARK: - Binary.ASCII.Serializable

extension RFC_2369.List.Post: Binary.ASCII.Serializable {
    static public func serialize<Buffer>(
        ascii post: RFC_2369.List.Post,
        into buffer: inout Buffer
    ) where Buffer: RangeReplaceableCollection, Buffer.Element == UInt8 {
        switch post {
        case .noPosting:
            buffer.append(contentsOf: [.ascii.N, .ascii.O])

        case .uris(let iris):
            for (index, iri) in iris.enumerated() {
                if index > 0 {
                    buffer.append(.ascii.comma)
                    buffer.append(.ascii.space)
                }
                buffer.append(.ascii.lessThanSign)
                buffer.append(ascii: iri)
                buffer.append(.ascii.greaterThanSign)
            }
        }
    }

    /// Parses a List-Post value from ASCII bytes (AUTHORITATIVE IMPLEMENTATION)
    ///
    /// ## RFC 2369 Section 3.4
    ///
    /// > The List-Post field describes the method for posting to the list.
    /// > This is typically the address of the list, but MAY be a moderator, or MAY be
    /// > unavailable (as indicated by the special value "NO").
    ///
    /// ## Category Theory
    ///
    /// Parsing transformation:
    /// - **Domain**: [UInt8] (ASCII bytes)
    /// - **Codomain**: RFC_2369.List.Post (structured data)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let post = try RFC_2369.List.Post(ascii: "NO".utf8)
    /// // post == .noPosting
    ///
    /// let post2 = try RFC_2369.List.Post(ascii: "<mailto:list@example.com>".utf8)
    /// // post2 == .uris([...])
    /// ```
    ///
    /// - Parameter bytes: The post value as ASCII bytes
    /// - Throws: `Error` if parsing fails
    public init<Bytes: Collection>(ascii bytes: Bytes, in context: Void = ()) throws(Error)
    where Bytes.Element == UInt8 {
        var byteArray = Array(bytes)

        // Strip leading/trailing whitespace
        while !byteArray.isEmpty
            && (byteArray.first == .ascii.space || byteArray.first == .ascii.htab)
        {
            byteArray.removeFirst()
        }
        while !byteArray.isEmpty
            && (byteArray.last == .ascii.space || byteArray.last == .ascii.htab)
        {
            byteArray.removeLast()
        }

        guard !byteArray.isEmpty else { throw Error.empty }

        // Check for "NO" (case-insensitive)
        if Array(bytes) == [UInt8.ascii.N, .ascii.O] {
            self = .noPosting
            return
        }

        // Parse angle-bracketed, comma-separated IRIs
        var iris: [RFC_3987.IRI] = []
        var current: [UInt8] = []
        var inBrackets = false

        for byte in byteArray {
            if byte == .ascii.lessThanSign {
                inBrackets = true
                current = []
            } else if byte == .ascii.greaterThanSign {
                inBrackets = false
                if !current.isEmpty {
                    let iriString = String(decoding: current, as: UTF8.self)
                    if let iri = try? RFC_3987.IRI(iriString) {
                        iris.append(iri)
                    } else {
                        throw Error.invalidIRI(iriString)
                    }
                }
            } else if inBrackets {
                current.append(byte)
            }
        }

        guard !iris.isEmpty else {
            throw Error.noURIs(String(decoding: byteArray, as: UTF8.self))
        }

        self = .uris(iris)
    }
}

// MARK: - Protocol Conformances

extension RFC_2369.List.Post: Binary.ASCII.RawRepresentable {
    public typealias RawValue = String
}

extension RFC_2369.List.Post: CustomStringConvertible {}

// MARK: - Codable

extension RFC_2369.List.Post: Codable {
    enum CodingKeys: String, CodingKey {
        case type
        case uris
    }

    enum PostType: String, Codable {
        case uris
        case noPosting
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PostType.self, forKey: .type)

        switch type {
        case .uris:
            let uris = try container.decode([RFC_3987.IRI].self, forKey: .uris)
            self = .uris(uris)
        case .noPosting:
            self = .noPosting
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .uris(let iris):
            try container.encode(PostType.uris, forKey: .type)
            try container.encode(iris, forKey: .uris)
        case .noPosting:
            try container.encode(PostType.noPosting, forKey: .type)
        }
    }
}
