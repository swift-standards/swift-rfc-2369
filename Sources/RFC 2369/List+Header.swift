import Foundation
import RFC_3987

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
    ///     subscribe: [
    ///         try RFC_3987.IRI("https://example.com/subscribe"),
    ///         try RFC_3987.IRI("mailto:subscribe@example.com")
    ///     ],
    ///     unsubscribe: [
    ///         try RFC_3987.IRI("https://example.com/unsubscribe")
    ///     ],
    ///     help: try RFC_3987.IRI("https://example.com/help"),
    ///     post: .uris([try RFC_3987.IRI("mailto:list@example.com")]),
    ///     owner: [try RFC_3987.IRI("mailto:owner@example.com")],
    ///     archive: try RFC_3987.IRI("https://example.com/archive")
    /// )
    ///
    /// // Render as email headers
    /// let emailHeaders = [String: String](listHeader: headers)
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
        ///
        /// Per RFC 2369 Section 3.1:
        /// > The List-Help field describes the command (preferably using mail) to obtain
        /// > assistance from the list. This may include instructions for both the user
        /// > and the mailing list system.
        public let help: RFC_3987.IRI?

        /// List-Unsubscribe: One or more URIs for unsubscribing
        ///
        /// Per RFC 2369 Section 3.2:
        /// > The List-Unsubscribe field describes the command (preferably using mail) to
        /// > directly unsubscribe the user (removing them from the list).
        public let unsubscribe: [RFC_3987.IRI]?

        /// List-Subscribe: One or more URIs for subscribing
        ///
        /// Per RFC 2369 Section 3.3:
        /// > The List-Subscribe field describes the command (preferably using mail) to
        /// > directly subscribe the user (request addition to the list).
        public let subscribe: [RFC_3987.IRI]?

        /// List-Post: URI(s) for posting to the list, or .noPosting for announcement lists
        ///
        /// Per RFC 2369 Section 3.4:
        /// > The List-Post field describes the method for posting to the list.
        /// > This is typically the address of the list, but MAY be a moderator, or MAY be
        /// > unavailable (as indicated by the special value "NO").
        public let post: Post?

        /// List-Owner: One or more URIs for contacting the list owner
        ///
        /// Per RFC 2369 Section 3.5:
        /// > The List-Owner field identifies the path to contact a human administrator
        /// > for the list. The mailto: scheme is often used, but other schemes may be
        /// > more appropriate.
        public let owner: [RFC_3987.IRI]?

        /// List-Archive: URI pointing to the list archive
        ///
        /// Per RFC 2369 Section 3.6:
        /// > The List-Archive field describes how to access archives for the list.
        public let archive: RFC_3987.IRI?

        /// Creates a new set of list headers
        ///
        /// - Parameters:
        ///   - help: URI for list help
        ///   - unsubscribe: URI(s) for unsubscribing
        ///   - subscribe: URI(s) for subscribing
        ///   - post: URI(s) for posting, or .noPosting
        ///   - owner: URI(s) for contacting owner
        ///   - archive: URI for list archive
        public init(
            help: RFC_3987.IRI? = nil,
            unsubscribe: [RFC_3987.IRI]? = nil,
            subscribe: [RFC_3987.IRI]? = nil,
            post: Post? = nil,
            owner: [RFC_3987.IRI]? = nil,
            archive: RFC_3987.IRI? = nil
        ) {
            self.help = help
            self.unsubscribe = unsubscribe
            self.subscribe = subscribe
            self.post = post
            self.owner = owner
            self.archive = archive
        }

        /// Creates list headers with IRI.Representable values (convenience)
        ///
        /// Accepts any IRI.Representable type such as Foundation URL.
        ///
        /// - Parameters:
        ///   - help: URI for list help (e.g., URL, RFC_3987.IRI)
        ///   - unsubscribe: URI(s) for unsubscribing
        ///   - subscribe: URI(s) for subscribing
        ///   - post: URI(s) for posting, or .noPosting
        ///   - owner: URI(s) for contacting owner
        ///   - archive: URI for list archive
        public init(
            help: (any RFC_3987.IRI.Representable)? = nil,
            unsubscribe: [any RFC_3987.IRI.Representable]? = nil,
            subscribe: [any RFC_3987.IRI.Representable]? = nil,
            post: Post? = nil,
            owner: [any RFC_3987.IRI.Representable]? = nil,
            archive: (any RFC_3987.IRI.Representable)? = nil
        ) {
            self.help = help.map { RFC_3987.IRI(unchecked: $0.iriString) }
            self.unsubscribe = unsubscribe?.map { RFC_3987.IRI(unchecked: $0.iriString) }
            self.subscribe = subscribe?.map { RFC_3987.IRI(unchecked: $0.iriString) }
            self.post = post
            self.owner = owner?.map { RFC_3987.IRI(unchecked: $0.iriString) }
            self.archive = archive.map { RFC_3987.IRI(unchecked: $0.iriString) }
        }

    }
}

// MARK: - Email Header Rendering

extension [String: String] {
    /// Creates email header dictionary from RFC 2369 list headers
    ///
    /// Renders the list headers as email header fields per RFC 2369 Section 2:
    ///
    /// > The contents of the list header fields mostly consist of angle-bracket
    /// > ('<', '>') enclosed URLs, with internal whitespace being ignored.
    /// > Multiple URLs in a single header field MUST be separated by commas.
    ///
    /// - Parameter listHeader: The RFC 2369 list header to render
    ///
    /// ## Example
    ///
    /// ```swift
    /// let headers = [String: String](listHeader: myListHeader)
    /// // Returns:
    /// // [
    /// //     "List-Help": "<https://example.com/help>",
    /// //     "List-Unsubscribe": "<https://example.com/unsubscribe>, <mailto:unsubscribe@example.com>",
    /// //     "List-Subscribe": "<https://example.com/subscribe>",
    /// //     "List-Post": "<mailto:list@example.com>",
    /// //     "List-Owner": "<mailto:owner@example.com>",
    /// //     "List-Archive": "<https://example.com/archive>"
    /// // ]
    /// ```
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
            headers["List-Post"] = String(listPost: post)
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
