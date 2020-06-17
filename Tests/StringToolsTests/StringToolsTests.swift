import XCTest
@testable import StringTools

final class StringToolsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(StringTools().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
