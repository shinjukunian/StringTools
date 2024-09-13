import XCTest
@testable import StringTools

extension NSAttributedString{
    var rubyRanges:[(NSRange,String)]{
        var ruby=[String]()
        var ranges=[NSRange]()
        self.enumerateAttribute(NSAttributedString.Key(kCTRubyAnnotationAttributeName as String), in: NSRange(location: 0, length: self.length), options: [], using: {r,range,stop in
            guard r != nil else {return}
            let r=r as! CTRubyAnnotation
            guard let text=CTRubyAnnotationGetTextForPosition(r, .before) as String? else{
                return
            }
            
            ruby.append(text)
            ranges.append(range)
        })
        return Array(zip(ranges, ruby))
    }
}



final class StringToolsTests: XCTestCase {
    
    
    @available(OSX 10.12, *)
    @available(iOS 10.0, *)
    func test熊_romaji() {
        let string="熊"
        let furigana="クマ"
        let attributed=string.furiganaAttributedString(furigana: furigana, kanjiOnly: true, useRomaji: true)
        let ruby=attributed.rubyRanges
        XCTAssert(ruby.isEmpty == false)
        let firstRuby=try! XCTUnwrap(ruby.first)
        XCTAssert(firstRuby.1 == "kuma")
        
    }
    
    @available(OSX 10.12, *)
    @available(iOS 10.0, *)
    func test引き出し() {
        let string="引き出し"
        let furigana="ひきだし"
        let attributed=string.furiganaAttributedString(furigana: furigana, kanjiOnly: true, useRomaji: false)
        let ruby=attributed.rubyRanges
        XCTAssert(ruby.isEmpty == false)
        let firstRuby=try! XCTUnwrap(ruby.first)
        XCTAssertEqual(firstRuby.1, "ひ　だ")
        let range=try! XCTUnwrap(string.range(of: "引き出"))
        XCTAssertEqual(firstRuby.0, NSRange(range, in: string))
        
    }
    
    
    
    @available(iOS 10.0, *)
    @available(OSX 10.12, *)
    func testCenter(){
        let string="上り坂"
        let furigana="のぼりざか"
        let attributed=string.furiganaAttributedString(furigana: furigana, kanjiOnly: true, useRomaji: false)
        let ruby=attributed.rubyRanges
        XCTAssert(ruby.isEmpty == false)
        let firstRuby=try! XCTUnwrap(ruby.first)
        XCTAssertEqual(firstRuby.1, "のぼ　ざか")
        

    }
    
    @available(iOS 10.0, *)
    @available(OSX 10.12, *)
    func testCenter2(){
        let string="歌い上げる"
        let furigana="うたいあげる"
        let attributed=string.furiganaAttributedString(furigana: furigana, kanjiOnly: true, useRomaji: false)
        let ruby=attributed.rubyRanges
        XCTAssert(ruby.isEmpty == false)
        let firstRuby=try! XCTUnwrap(ruby.first)
        XCTAssertEqual(firstRuby.1, "うた　あ")
        
    }
    
    @available(iOS 10.0, *)
    func testCenter2_romaji(){
        let string="歌い上げる"
        let furigana="うたいあげる"
        let attributed=string.furiganaAttributedString(furigana: furigana, kanjiOnly: true, useRomaji: true)
        let ruby=attributed.rubyRanges
        XCTAssert(ruby.isEmpty == false)
        let firstRuby=try! XCTUnwrap(ruby.first)
        XCTAssertEqual(firstRuby.1, "uta　a")
        let range=try! XCTUnwrap(string.range(of: "歌い上"))
        XCTAssertEqual(firstRuby.0, NSRange(range, in: string))
        
    }
    
    @available(iOS 10.0, *)
    func testFurigana(){
        let string="歌い上げる"
        let att=string.furiganaAttributedString(kanjiOnly: true, useRomaji: false)
        XCTAssert(att.length > 0)
        
        let string2="熊はとても怖いですよ。"
        let att2=string2.furiganaAttributedString(kanjiOnly: true, useRomaji: false)
        XCTAssert(att2.length > 0)
        
        let ruby=att2.rubyRanges
        XCTAssert(ruby.isEmpty == false)
        let firstRuby=try! XCTUnwrap(ruby.first)
        XCTAssertEqual(firstRuby.1, "くま")
        XCTAssertEqual(firstRuby.0, NSRange(string2.range(of: "熊")!, in: string2))
        let secondRuby=ruby[1]
        XCTAssertEqual(secondRuby.1, "こわ")
        XCTAssertEqual(secondRuby.0, NSRange(string2.range(of: "怖")!, in: string2))
        
    }
    
    @available(iOS 10.0, *)
    func test通じて(){
        let string="通じて"
        let att=string.furiganaAttributedString(kanjiOnly: true, useRomaji: false)
        XCTAssert(att.length > 0)
        let ruby=att.rubyRanges
        XCTAssert(ruby.isEmpty == false)
        let firstRuby=try! XCTUnwrap(ruby.first)
        XCTAssertEqual(firstRuby.1, "つう")
        XCTAssertEqual(firstRuby.0, NSRange(string.range(of: "通")!, in: string))
        
    }
    
    func testお電話(){
        let string="お電話"
        let att=string.furiganaAttributedString(kanjiOnly: true, useRomaji: true)
        XCTAssert(att.length > 0)
        let ruby=att.rubyRanges
        XCTAssert(ruby.isEmpty == false)
        let firstRuby=try! XCTUnwrap(ruby.first)
        XCTAssertEqual(firstRuby.1, "denwa")
        XCTAssertEqual(firstRuby.0, NSRange(string.range(of: "電話")!, in: string))
        
    }
    
    func testMixed(){
        let string="お電話番号は１１１１１です。"
        let att=string.furiganaAttributedString(kanjiOnly: false, useRomaji: true, convertAll: true)
        XCTAssert(att.length > 0)
        let ruby=att.rubyRanges
        XCTAssert(ruby.isEmpty == false)
        let firstRuby=try! XCTUnwrap(ruby.first)
        XCTAssertEqual(firstRuby.1, "o")
        XCTAssertEqual(firstRuby.0, NSRange(string.range(of: "お")!, in: string))
        
    }
    
    
    
    
    

    @available(OSX 10.12, *)
    @available(iOS 10.0, *)
    static var allTests = [
        ("testExample", test熊_romaji),
    ]
}
