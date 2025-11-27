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
/// Following the standard pattern, RFC 2369 re-exports:
/// - INCITS 4-1986 (ASCII byte constants)
/// - RFC 3987 (IRI types)

@_exported public import INCITS_4_1986
@_exported public import RFC_3987
