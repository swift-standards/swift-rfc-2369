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
/// // Serialize to bytes
/// let bytes = [UInt8](headers)
///
/// // Or render to email headers dictionary
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
/// This module re-exports RFC 3987 (IRI) and INCITS 4-1986 (ASCII) types for convenience.
public enum RFC_2369 {}
