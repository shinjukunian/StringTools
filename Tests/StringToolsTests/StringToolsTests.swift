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
    
    
    
    @available(iOS 10.0, *)
    @available(OSX 10.12, *)
    func testCenter(){
        let string="上り坂"
        let furigana="のぼりざか"
        let ruby=string.furiganaAttributedString(furigana: furigana, kanjiOnly: true, useRomaji: false)
        
        ruby.enumerateAttribute(NSAttributedString.Key(kCTRubyAnnotationAttributeName as String), in: NSRange(location: 0, length: ruby.length), options: [], using: {annotation, range, _ in
            if annotation == nil {return}
            let annotation=annotation as! CTRubyAnnotation
            guard let rubyString=CTRubyAnnotationGetTextForPosition(annotation, .before) as String? else {
                XCTFail()
                return
            }
            XCTAssertEqual(rubyString, "のぼ　ざか")
        })
    }
    
    @available(iOS 10.0, *)
    @available(OSX 10.12, *)
    func testCenter2(){
        let string="歌い上げる"
        let furigana="うたいあげる"
        let ruby=string.furiganaAttributedString(furigana: furigana, kanjiOnly: true, useRomaji: false)
        
        ruby.enumerateAttribute(NSAttributedString.Key(kCTRubyAnnotationAttributeName as String), in: NSRange(location: 0, length: ruby.length), options: [], using: {annotation, range, _ in
            if annotation == nil {return}
            let annotation=annotation as! CTRubyAnnotation
            guard let rubyString=CTRubyAnnotationGetTextForPosition(annotation, .before) as String? else {
                XCTFail()
                return
            }
            XCTAssertEqual(rubyString, "うた　あ")
        })
    }
    
    @available(iOS 10.0, *)
    func testFurigana(){
        let string="歌い上げる"
        let att=string.furiganaAttributedString(kanjiOnly: true, useRomaji: false)
        XCTAssert(att.length > 0)
        let string2="熊はとても怖いですよ。"
        let att2=string2.furiganaAttributedString(kanjiOnly: true, useRomaji: false)
        XCTAssert(att2.length > 0)
    }
    
    
    

    @available(OSX 10.12, *)
    @available(iOS 10.0, *)
    static var allTests = [
        ("testExample", testRomajiFurigana),
    ]
}
