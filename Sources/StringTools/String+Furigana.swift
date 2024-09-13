//
//  File.swift
//  
//
//  Created by Morten Bertz on 2020/01/24.
//

import Foundation
import CoreText

@available(watchOS 3.0, *)
@available(OSX 10.12, *)
@available(iOS 10.0, *)
extension String{
    
    public struct SystemTokenizerAnnotation{
        
        public let base:String
        public let reading:String
        public let range:Range<String.Index>
        
        public init(base: String, reading: String, range: Range<String.Index>) {
            self.base = base
            self.reading = reading
            self.range = range
        }
        
        func cleanupFurigana(text:String)->SystemTokenizerAnnotation{
            var range=self.range
            var transliteration=self.reading
            
            let hiraganaRanges=self.base.hiraganaRanges
            
            for hiraganaRange in hiraganaRanges{
                switch hiraganaRange {
                case _ where hiraganaRange.upperBound == self.base.endIndex:
                    let trailingDistance=self.base.distance(from: self.base.endIndex, to: hiraganaRange.lowerBound)
                    let newEndIndex=text.index(range.upperBound, offsetBy: trailingDistance)
                    range=range.lowerBound..<newEndIndex
                    let transliterationEnd=transliteration.index(transliteration.endIndex, offsetBy: trailingDistance)
                    let newTransliterationRange=transliteration.startIndex..<transliterationEnd
                    let t2=transliteration[newTransliterationRange]
                    transliteration=String(t2)
                case _ where hiraganaRange.lowerBound == self.base.startIndex:
                    let leadingDistance=self.base.distance(from: self.base.startIndex, to: hiraganaRange.upperBound)
                    let newStartIndex=text.index(range.lowerBound, offsetBy: leadingDistance)// wrong?
                    range=newStartIndex..<range.upperBound
                    let transliterationStart=transliteration.index(transliteration.startIndex, offsetBy: leadingDistance)
                    let newTransliterationRange=transliterationStart..<transliteration.endIndex
                    let t2=transliteration[newTransliterationRange]
                    transliteration=String(t2)
                default:
                    let detectedCenterHiragana=self.base[hiraganaRange]
                    transliteration = transliteration.replacingOccurrences(of: detectedCenterHiragana, with: "　")
                }
            }
            
            return SystemTokenizerAnnotation(base: base, reading: transliteration, range: range)
        }
    }
    
    public func furiganaAttributedString(furigana:String, kanjiOnly:Bool = true, useRomaji:Bool = false) -> NSAttributedString{
        
        var furiganaAnnotation=SystemTokenizerAnnotation(base: self, reading: furigana, range: self.startIndex..<self.endIndex)
        if kanjiOnly{
            furiganaAnnotation=furiganaAnnotation.cleanupFurigana(text: self)
        }
        let annotation:CTRubyAnnotation
        
        if useRomaji{
            let romajiString=furiganaAnnotation.reading.romanizedString(method: .hepburn)
            annotation=CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, romajiString as CFString, [:] as CFDictionary)
        }
        else{
            annotation=CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, furiganaAnnotation.reading as CFString, [:] as CFDictionary)
        }
        
        let att=NSMutableAttributedString(string: self)
        
        if furiganaAnnotation.reading.isEmpty == false{
            att.addAttributes([NSAttributedString.Key(kCTRubyAnnotationAttributeName as String):annotation], range: NSRange(furiganaAnnotation.range, in: self))
        }
        return att
        
    }
    
    
    public var furiganaAnnotations:[SystemTokenizerAnnotation]{
        let japaneseLocale=Locale(identifier: "ja_JP")
        
        let nsRange=NSRange((self.startIndex..<self.endIndex), in: self)
        
        let tokenizer=CFStringTokenizerCreate(nil, self as CFString, CFRange(location: nsRange.location, length: nsRange.length), kCFStringTokenizerUnitWordBoundary, japaneseLocale as CFLocale)
        
        var annotations=[SystemTokenizerAnnotation]()
        
        var result=CFStringTokenizerAdvanceToNextToken(tokenizer)
        
        let kanjiCharacterSet=CharacterSet.kanji
        
        while !result.isEmpty {
            
            let annotation:SystemTokenizerAnnotation? = autoreleasepool{
                defer {
                    result=CFStringTokenizerAdvanceToNextToken(tokenizer)
                }
                
                let cfRange=CFStringTokenizerGetCurrentTokenRange(tokenizer)
                guard let range=Range<String.Index>.init(NSRange(location: cfRange.location, length: cfRange.length), in: self) else{return nil}
                let subString=String(self[range])
                
                let subStringSet=CharacterSet(charactersIn: subString)
                
                if kanjiCharacterSet.isDisjoint(with: subStringSet) == false{
                    
                    let cTypeRef=CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription)
                    guard let typeRef=cTypeRef, CFGetTypeID(typeRef) == CFStringGetTypeID() else {return nil}
                    let latinString=typeRef as! CFString
                    guard let hiragana=(latinString as String).applyingTransform(.latinToHiragana, reverse: false) else{return nil}
                    
                    return SystemTokenizerAnnotation(base: subString, reading: hiragana, range: range)
                    
                }
                else{
                    return SystemTokenizerAnnotation(base: subString, reading: subString, range: range)
                }
            }
            
            guard let annotation = annotation else {
                continue
            }
            
            annotations.append(annotation)
        }
        return annotations
    }
    
    
    public func furiganaAttributedString(kanjiOnly:Bool = true, useRomaji:Bool = false, convertAll:Bool = false)-> NSAttributedString{
        
        let annotations:[SystemTokenizerAnnotation]
        if convertAll{
            annotations=self.furiganaAnnotations.filter({$0.base.japaneseScriptType != .noJapaneseScript})

        }
        else{
            annotations=self.furiganaAnnotations.filter({$0.base.containsKanjiCharacters})
        }
        
        let att=NSMutableAttributedString(string: self)
        
        for var annotation in annotations{
            if kanjiOnly{
                annotation=annotation.cleanupFurigana(text: self)
            }            
            let transliteration:String
            if useRomaji{
                transliteration=annotation.reading.romanizedString()
            }
            else{
                transliteration=annotation.reading
            }
            
            
            let ruby=CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, transliteration as CFString, [:] as CFDictionary)
            
            att.addAttributes([NSAttributedString.Key(kCTRubyAnnotationAttributeName as String):ruby], range: NSRange(annotation.range, in: self))
        }
        return att
    }
    
    
}
