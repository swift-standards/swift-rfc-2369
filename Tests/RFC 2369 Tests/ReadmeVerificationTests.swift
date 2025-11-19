import RFC_3987
import Testing

@testable import RFC_2369

@Suite
struct `README Verification` {

    @Test
    func `Example from README: Creating List Headers`() throws {
        // From README line 41-52
        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help"),
            unsubscribe: [
                try RFC_3987.IRI("https://example.com/unsubscribe"),
                try RFC_3987.IRI("mailto:unsubscribe@example.com"),
            ],
            subscribe: [try RFC_3987.IRI("https://example.com/subscribe")],
            post: .uris([try RFC_3987.IRI("mailto:list@example.com")]),
            owner: [try RFC_3987.IRI("mailto:owner@example.com")],
            archive: try RFC_3987.IRI("https://example.com/archive")
        )

        #expect(headers.help != nil)
        #expect(headers.unsubscribe?.count == 2)
    }

    @Test
    func `Example from README: Using Foundation URLs`() {
        // From README line 58-63
        let headers = RFC_2369.List.Header(
            help: URL(string: "https://example.com/help")!,
            unsubscribe: [URL(string: "https://example.com/unsubscribe")!]
        )

        #expect(headers.help?.value == "https://example.com/help")
    }

    @Test
    func `Example from README: Rendering as Email Headers`() throws {
        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help")
        )

        // From README line 68
        let emailHeaders = [String: String](listHeader: headers)

        #expect(emailHeaders["List-Help"] == "<https://example.com/help>")
    }

    @Test
    func `Example from README: Announcement-Only Lists`() throws {
        // From README line 82-87
        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help"),
            post: .noPosting  // Renders as "List-Post: NO"
        )

        let emailHeaders = [String: String](listHeader: headers)
        #expect(emailHeaders["List-Post"] == "NO")
    }
}
