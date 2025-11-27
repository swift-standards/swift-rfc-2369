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

// MARK: - UInt8.Serializable Conformance

extension RFC_2369.List.Post: UInt8.Serializable {
    public static let serialize: @Sendable (Self) -> [UInt8] = [UInt8].init
}

// MARK: - [UInt8] Conversion

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

// MARK: - CustomStringConvertible

extension RFC_2369.List.Post: CustomStringConvertible {
    /// String representation of the post value
    ///
    /// Renders as "NO" for `.noPosting` or angle-bracketed URIs for `.uris`.
    public var description: String {
        String(decoding: self.bytes, as: UTF8.self)
    }
}

// MARK: - StringProtocol Conversion

extension StringProtocol {
    /// Create a string from an RFC 2369 List.Post value
    ///
    /// - Parameter post: The post value to convert
    public init(_ post: RFC_2369.List.Post) {
        self = Self(decoding: post.bytes, as: UTF8.self)
    }
}

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
