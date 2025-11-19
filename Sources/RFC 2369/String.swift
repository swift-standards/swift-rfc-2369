//
//  File.swift
//  swift-rfc-2369
//
//  Created by Coen ten Thije Boonkkamp on 19/11/2025.
//

// MARK: - Header Value Rendering

extension String {
    /// Creates RFC 2369 compliant List-Post header value
    ///
    /// Renders the post value according to RFC 2369 Section 3.4.
    ///
    /// - Parameter listPost: The list post value to render
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // URIs are enclosed in angle brackets and comma-separated
    /// let value = String(listPost: .uris([iri1, iri2]))
    /// // Returns: "<mailto:list@host.com>, <mailto:moderator@host.com>"
    ///
    /// // Special NO value
    /// let noValue = String(listPost: .noPosting)
    /// // Returns: "NO"
    /// ```
    public init(listPost: RFC_2369.List.Post) {
        switch listPost {
        case .uris(let iris):
            self =
                iris
                .map { "<\($0.value)>" }
                .joined(separator: ", ")
        case .noPosting:
            self = "NO"
        }
    }
}
