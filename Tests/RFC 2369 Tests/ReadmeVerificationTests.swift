import RFC_3987
import Testing

@testable import RFC_2369

@Suite
struct `README Verification` {

    @Test
    func `Example from README: Creating List Headers`() {
        // From README line 41-52
        let headers = RFC_2369.List.Header(
            help: RFC_3987.IRI("https://example.com/help"),
            unsubscribe: [
                RFC_3987.IRI("https://example.com/unsubscribe"),
                RFC_3987.IRI("mailto:unsubscribe@example.com"),
            ],
            subscribe: [RFC_3987.IRI("https://example.com/subscribe")],
            post: .uris([RFC_3987.IRI("mailto:list@example.com")]),
            owner: [RFC_3987.IRI("mailto:owner@example.com")],
            archive: RFC_3987.IRI("https://example.com/archive")
        )

        #expect(headers.help != nil)
        #expect(headers.unsubscribe?.count == 2)
    }

    @Test
    func `Example from README: Rendering as Email Headers`() {
        let headers = RFC_2369.List.Header(
            help: RFC_3987.IRI("https://example.com/help")
        )

        // From README line 68
        let emailHeaders = [String: String](listHeader: headers)

        #expect(emailHeaders["List-Help"] == "<https://example.com/help>")
    }

    @Test
    func `Example from README: Announcement-Only Lists`() {
        // From README line 82-87
        let headers = RFC_2369.List.Header(
            help: RFC_3987.IRI("https://example.com/help"),
            post: .noPosting  // Renders as "List-Post: NO"
        )

        let emailHeaders = [String: String](listHeader: headers)
        #expect(emailHeaders["List-Post"] == "NO")
    }
}
