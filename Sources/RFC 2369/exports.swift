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

/// Re-export dependencies for downstream convenience
///
/// Following the standard pattern, RFC 2369 re-exports RFC 3987 (IRI)
/// so that consumers get access to IRI types without additional imports.

@_exported public import RFC_3987
