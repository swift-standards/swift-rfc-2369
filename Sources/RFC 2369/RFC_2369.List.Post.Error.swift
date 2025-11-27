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

extension RFC_2369.List.Post {
    /// Errors during List-Post value parsing
    public enum Error: Swift.Error, Sendable, Equatable, CustomStringConvertible {
        case empty
        case invalidIRI(_ value: String)
        case noURIs(_ value: String)

        public var description: String {
            switch self {
            case .empty:
                return "List-Post value cannot be empty"
            case .invalidIRI(let value):
                return "Invalid IRI in List-Post: '\(value)'"
            case .noURIs(let value):
                return "No valid URIs found in List-Post: '\(value)'"
            }
        }
    }
}
