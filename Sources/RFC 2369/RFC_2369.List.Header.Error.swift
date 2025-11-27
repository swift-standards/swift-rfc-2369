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

extension RFC_2369.List.Header {
    /// Errors during list header parsing
    public enum Error: Swift.Error, Sendable, Equatable, CustomStringConvertible {
        case invalidIRI(_ value: String)

        public var description: String {
            switch self {
            case .invalidIRI(let value):
                return "Invalid IRI in list header: '\(value)'"
            }
        }
    }
}
