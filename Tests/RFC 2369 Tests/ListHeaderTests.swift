import RFC_3987
import Testing

@testable import RFC_2369

@Suite("RFC 2369 List Header Tests")
struct ListHeaderTests {

    // MARK: - Basic Initialization

    @Test("List headers can be created with all fields")
    func testCompleteHeaders() throws {
        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help"),
            unsubscribe: [
                try RFC_3987.IRI("https://example.com/unsubscribe"),
                try RFC_3987.IRI("mailto:unsubscribe@example.com"),
            ],
            subscribe: [
                try RFC_3987.IRI("https://example.com/subscribe")
            ],
            post: .uris([try RFC_3987.IRI("mailto:list@example.com")]),
            owner: [try RFC_3987.IRI("mailto:owner@example.com")],
            archive: try RFC_3987.IRI("https://example.com/archive")
        )

        #expect(headers.help != nil)
        #expect(headers.unsubscribe?.count == 2)
        #expect(headers.subscribe?.count == 1)
        #expect(headers.owner?.count == 1)
        #expect(headers.archive != nil)
    }

    @Test("List headers can be created with minimal fields")
    func testMinimalHeaders() {
        let headers = RFC_2369.List.Header()

        #expect(headers.help == nil)
        #expect(headers.unsubscribe == nil)
        #expect(headers.subscribe == nil)
        #expect(headers.post == nil)
        #expect(headers.owner == nil)
        #expect(headers.archive == nil)
    }

    @Test("List headers can be created with IRI.Representable (URL)")
    func testURLConvenience() throws {
        let helpURL = URL(string: "https://example.com/help")!
        let unsubscribeURL = URL(string: "https://example.com/unsubscribe")!

        let headers = RFC_2369.List.Header(
            help: helpURL,
            unsubscribe: [unsubscribeURL]
        )

        #expect(headers.help?.value == "https://example.com/help")
        #expect(headers.unsubscribe?.first?.value == "https://example.com/unsubscribe")
    }

    // MARK: - Email Header Rendering

    @Test("Renders single URI headers correctly per RFC 2369")
    func testSingleURIRendering() throws {
        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help"),
            archive: try RFC_3987.IRI("https://example.com/archive")
        )

        let emailHeaders = [String: String](listHeader: headers)

        #expect(emailHeaders["List-Help"] == "<https://example.com/help>")
        #expect(emailHeaders["List-Archive"] == "<https://example.com/archive>")
    }

    @Test("Renders multiple URI headers with comma separation per RFC 2369")
    func testMultipleURIRendering() throws {
        let headers = try RFC_2369.List.Header(
            unsubscribe: [
                try RFC_3987.IRI("https://example.com/unsubscribe"),
                try RFC_3987.IRI("mailto:unsubscribe@example.com?subject=unsubscribe"),
            ],
            subscribe: [
                try RFC_3987.IRI("https://example.com/subscribe"),
                try RFC_3987.IRI("mailto:subscribe@example.com"),
            ]
        )

        let emailHeaders = [String: String](listHeader: headers)

        // Per RFC 2369: Multiple URLs MUST be separated by commas
        #expect(
            emailHeaders["List-Unsubscribe"]
                == "<https://example.com/unsubscribe>, <mailto:unsubscribe@example.com?subject=unsubscribe>"
        )
        #expect(
            emailHeaders["List-Subscribe"]
                == "<https://example.com/subscribe>, <mailto:subscribe@example.com>"
        )
    }

    @Test("Renders List-Post with URIs correctly")
    func testPostURIRendering() throws {
        let headers = RFC_2369.List.Header(
            post: .uris([
                try RFC_3987.IRI("mailto:list@example.com")
            ])
        )

        let emailHeaders = [String: String](listHeader: headers)

        #expect(emailHeaders["List-Post"] == "<mailto:list@example.com>")
    }

    @Test("Renders List-Post NO for announcement lists per RFC 2369")
    func testPostNoPostingRendering() {
        let headers = RFC_2369.List.Header(
            post: .noPosting
        )

        let emailHeaders = [String: String](listHeader: headers)

        // Per RFC 2369 Section 3.4: "NO" indicates posting not allowed
        #expect(emailHeaders["List-Post"] == "NO")
    }

    @Test("Does not include headers with nil values")
    func testNilHeadersExcluded() throws {
        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help")
        )

        let emailHeaders = [String: String](listHeader: headers)

        #expect(emailHeaders.count == 1)
        #expect(emailHeaders["List-Help"] != nil)
        #expect(emailHeaders["List-Unsubscribe"] == nil)
        #expect(emailHeaders["List-Subscribe"] == nil)
        #expect(emailHeaders["List-Post"] == nil)
        #expect(emailHeaders["List-Owner"] == nil)
        #expect(emailHeaders["List-Archive"] == nil)
    }

    // MARK: - RFC 2369 Examples

    @Test("Example from RFC 2369 Section 4.1")
    func testRFC2369Example1() throws {
        // RFC 2369 Example:
        // List-Help: <mailto:list@host.com?subject=help> (List Instructions)
        // List-Unsubscribe: <mailto:list@host.com?subject=unsubscribe>
        // List-Subscribe: <mailto:list@host.com?subject=subscribe>
        // List-Post: <mailto:list@host.com>
        // List-Owner: <mailto:listmom@host.com> (Contact Person for Help)

        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("mailto:list@host.com?subject=help"),
            unsubscribe: [try RFC_3987.IRI("mailto:list@host.com?subject=unsubscribe")],
            subscribe: [try RFC_3987.IRI("mailto:list@host.com?subject=subscribe")],
            post: .uris([try RFC_3987.IRI("mailto:list@host.com")]),
            owner: [try RFC_3987.IRI("mailto:listmom@host.com")]
        )

        let emailHeaders = [String: String](listHeader: headers)

        #expect(emailHeaders["List-Help"] == "<mailto:list@host.com?subject=help>")
        #expect(emailHeaders["List-Unsubscribe"] == "<mailto:list@host.com?subject=unsubscribe>")
        #expect(emailHeaders["List-Subscribe"] == "<mailto:list@host.com?subject=subscribe>")
        #expect(emailHeaders["List-Post"] == "<mailto:list@host.com>")
        #expect(emailHeaders["List-Owner"] == "<mailto:listmom@host.com>")
    }

    @Test("Example from RFC 2369 Section 4.2 - Web-based list")
    func testRFC2369Example2() throws {
        // RFC 2369 Example: Web-based mailing list
        // List-Help: <http://www.host.com/list/> <mailto:list-help@host.com>
        // List-Unsubscribe: <http://www.host.com/list.cgi?cmd=unsub&lst=list>, <mailto:list-request@host.com?subject=unsubscribe>
        // List-Post: <mailto:list@host.com>

        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("http://www.host.com/list/"),
            unsubscribe: [
                try RFC_3987.IRI("http://www.host.com/list.cgi?cmd=unsub&lst=list"),
                try RFC_3987.IRI("mailto:list-request@host.com?subject=unsubscribe"),
            ],
            post: .uris([try RFC_3987.IRI("mailto:list@host.com")])
        )

        let emailHeaders = [String: String](listHeader: headers)

        #expect(emailHeaders["List-Help"] == "<http://www.host.com/list/>")
        #expect(
            emailHeaders["List-Unsubscribe"]?.contains(
                "<http://www.host.com/list.cgi?cmd=unsub&lst=list>"
            ) == true
        )
        #expect(
            emailHeaders["List-Unsubscribe"]?.contains(
                "<mailto:list-request@host.com?subject=unsubscribe>"
            ) == true
        )
    }

    @Test("Example from RFC 2369 Section 4.3 - Announcement-only list")
    func testRFC2369Example3() throws {
        // RFC 2369 Example: Announcement-only list
        // List-Help: <mailto:list-info@host.com>
        // List-Post: NO (posting not allowed on this list)

        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("mailto:list-info@host.com"),
            post: .noPosting
        )

        let emailHeaders = [String: String](listHeader: headers)

        #expect(emailHeaders["List-Help"] == "<mailto:list-info@host.com>")
        #expect(emailHeaders["List-Post"] == "NO")
    }

    // MARK: - List.Post Tests

    @Test("List.Post.uris renders correctly")
    func testPostURIs() throws {
        let post = RFC_2369.List.Post.uris([
            try RFC_3987.IRI("mailto:list@example.com"),
            try RFC_3987.IRI("mailto:moderator@example.com"),
        ])

        let headerValue = String(listPost: post)

        #expect(headerValue == "<mailto:list@example.com>, <mailto:moderator@example.com>")
    }

    @Test("List.Post.noPosting renders as NO")
    func testPostNoPosting() {
        let post = RFC_2369.List.Post.noPosting

        let headerValue = String(listPost: post)

        #expect(headerValue == "NO")
    }

    // MARK: - Codable Tests

    @Test("List.Header is Codable")
    func testHeaderCodable() throws {
        let original = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help"),
            unsubscribe: [try RFC_3987.IRI("https://example.com/unsubscribe")],
            post: .noPosting
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RFC_2369.List.Header.self, from: encoded)

        #expect(decoded.help == original.help)
        #expect(decoded.unsubscribe == original.unsubscribe)
        #expect(decoded.post == original.post)
    }

    @Test("List.Post is Codable")
    func testPostCodable() throws {
        let urisPost = RFC_2369.List.Post.uris([try RFC_3987.IRI("mailto:list@example.com")])
        let encodedURIs = try JSONEncoder().encode(urisPost)
        let decodedURIs = try JSONDecoder().decode(RFC_2369.List.Post.self, from: encodedURIs)
        #expect(decodedURIs == urisPost)

        let noPost = RFC_2369.List.Post.noPosting
        let encodedNo = try JSONEncoder().encode(noPost)
        let decodedNo = try JSONDecoder().decode(RFC_2369.List.Post.self, from: encodedNo)
        #expect(decodedNo == noPost)
    }

    // MARK: - Hashable Tests

    @Test("List.Header is Hashable")
    func testHeaderHashable() throws {
        let header1 = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help")
        )
        let header2 = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help")
        )
        let header3 = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/different")
        )

        #expect(header1 == header2)
        #expect(header1 != header3)

        var set = Set<RFC_2369.List.Header>()
        set.insert(header1)
        set.insert(header2)
        set.insert(header3)

        #expect(set.count == 2)
    }

    // MARK: - Sendable Tests

    @Test("List.Header is Sendable")
    func testHeaderSendable() async throws {
        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help")
        )

        await withCheckedContinuation { continuation in
            Task {
                let _ = headers  // Can use in async context
                continuation.resume()
            }
        }
    }
}
