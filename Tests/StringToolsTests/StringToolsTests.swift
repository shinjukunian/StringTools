import XCTest
@testable import StringTools

final class StringToolsTests: XCTestCase {
    
    @available(OSX 10.12, *)
    @available(iOS 10.0, *)
    func testRomajiFurigana() {
        let string="引き出し"
        let furigana="ひきだし"
        let attributed=string.furiganaAttributedString(furigana: furigana, kanjiOnly: true, useRomaji: true)
        let ruby=attributed.attribute(NSAttributedString.Key(kCTRubyAnnotationAttributeName as String), at: 0, effectiveRange: nil) as! CTRubyAnnotation
        
        guard let text=CTRubyAnnotationGetTextForPosition(ruby, .before) as String? else{
            XCTFail()
            return
        }
        XCTAssertEqual(text, "hi　da")
        
    }

    @available(OSX 10.12, *)
    @available(iOS 10.0, *)
    static var allTests = [
        ("testExample", testRomajiFurigana),
    ]
}
