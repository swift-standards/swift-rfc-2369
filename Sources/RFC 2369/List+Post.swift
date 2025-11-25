import RFC_3987

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
    /// // Render to header value
    /// print(String(listPost: post))  // "<mailto:list@example.com>"
    /// print(String(listPost: announcementPost))  // "NO"
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
