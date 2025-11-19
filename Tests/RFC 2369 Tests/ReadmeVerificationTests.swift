import RFC_3987
import Testing

@testable import RFC_2369

@Suite("README Verification")
struct ReadmeVerificationTests {

    @Test("Example from README: Creating List Headers")
    func exampleCreatingListHeaders() throws {
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

    @Test("Example from README: Using Foundation URLs")
    func exampleFoundationURLs() {
        // From README line 58-63
        let headers = RFC_2369.List.Header(
            help: URL(string: "https://example.com/help")!,
            unsubscribe: [URL(string: "https://example.com/unsubscribe")!]
        )

        #expect(headers.help?.value == "https://example.com/help")
    }

    @Test("Example from README: Rendering as Email Headers")
    func exampleRenderingHeaders() throws {
        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help")
        )

        // From README line 68
        let emailHeaders = [String: String](listHeader: headers)

        #expect(emailHeaders["List-Help"] == "<https://example.com/help>")
    }

    @Test("Example from README: Announcement-Only Lists")
    func exampleAnnouncementList() throws {
        // From README line 82-87
        let headers = try RFC_2369.List.Header(
            help: try RFC_3987.IRI("https://example.com/help"),
            post: .noPosting  // Renders as "List-Post: NO"
        )

        let emailHeaders = [String: String](listHeader: headers)
        #expect(emailHeaders["List-Post"] == "NO")
    }
}
