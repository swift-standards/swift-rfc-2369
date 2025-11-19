@_exported import RFC_3987

/// RFC 2369: The Use of URLs as Meta-Syntax for Core Mail List Commands
///
/// This module implements the List-* headers defined in RFC 2369 for automated mail list
/// management through standard email headers.
///
/// RFC 2369 establishes six standardized header fields that email distribution lists use
/// to provide information about list management commands:
///
/// - `List-Help`: Provides access to list help information
/// - `List-Subscribe`: Command to subscribe to the list
/// - `List-Unsubscribe`: Command to unsubscribe from the list
/// - `List-Post`: Address for posting messages (or NO for announcement lists)
/// - `List-Owner`: Contact address for the list owner/moderator
/// - `List-Archive`: Location of the list archive
///
/// ## Usage Example
///
/// ```swift
/// let headers = try RFC_2369.List.Header(
///     subscribe: [try RFC_3987.IRI("https://example.com/subscribe")],
///     unsubscribe: [try RFC_3987.IRI("https://example.com/unsubscribe")],
///     help: try RFC_3987.IRI("https://example.com/help")
/// )
///
/// // Render to email headers
/// let emailHeaders = [String: String](listHeader: headers)
/// // ["List-Subscribe": "<https://example.com/subscribe>", ...]
/// ```
///
/// ## RFC Reference
///
/// From RFC 2369:
///
/// > The mailing list header fields are subject to the encoding and character
/// > restrictions for mail headers as described in [RFC 822].
///
/// > The contents of the list header fields mostly consist of angle-bracket
/// > ('<', '>') enclosed URLs, with internal whitespace being ignored.
///
/// This module re-exports RFC 3987 (IRI) types for convenience, as IRIs are
/// fundamental to list header values.
public enum RFC_2369 {
    /// Errors that can occur when working with list headers
    public enum ListError: Error, Hashable, Sendable {
        case invalidHeaderValue(String)
        case missingRequiredHeader(String)
        case invalidPostValue(String)
    }
}

// MARK: - LocalizedError Conformance

extension RFC_2369.ListError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidHeaderValue(let value):
            return "Invalid list header value: '\(value)'. Values must be valid IRIs per RFC 2369."
        case .missingRequiredHeader(let header):
            return "Missing required list header: '\(header)'"
        case .invalidPostValue(let value):
            return "Invalid List-Post value: '\(value)'. Must be 'NO' or one or more IRIs."
        }
    }
}
