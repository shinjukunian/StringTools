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
    }
    
    public func furiganaAttributedString(furigana:String, kanjiOnly:Bool = true, useRomaji:Bool = false) -> NSAttributedString{
        
        let transliteration=furigana.cleanupFurigana(base: self)
        let range=self.startIndex..<self.endIndex
        let annotation:CTRubyAnnotation
        if useRomaji{
            let romajiString=transliteration.romanizedString(method: .hepburn)
            annotation=CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, romajiString as CFString, [:] as CFDictionary)
        }
        else{
            annotation=CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, transliteration as CFString, [:] as CFDictionary)
        }
        
        
        let att=NSMutableAttributedString(string: self)
        if transliteration.count > 0{
            att.addAttributes([NSAttributedString.Key(kCTRubyAnnotationAttributeName as String):annotation], range: NSRange(range, in: self))
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
    
    
    public func furiganaAttributedString(kanjiOnly:Bool = true, useRomaji:Bool = false)-> NSAttributedString{
        let annotations=self.furiganaAnnotations.filter({$0.base.containsKanjiCharacters})
        let att=NSMutableAttributedString(string: self)
        for annotation in annotations{
            let transliteration:String
            switch(kanjiOnly,useRomaji){
            case (true,true):
                transliteration = annotation.reading.cleanupFurigana(base: annotation.base).romanizedString()
            case (true,false):
                transliteration = annotation.reading.cleanupFurigana(base: annotation.base)
            case (false,true):
                transliteration = annotation.reading.romanizedString()
            case (false,false):
                transliteration=annotation.reading
            }
            let ruby=CTRubyAnnotationCreateWithAttributes(.auto, .auto, .before, transliteration as CFString, [:] as CFDictionary)
            att.addAttributes([NSAttributedString.Key(kCTRubyAnnotationAttributeName as String):ruby], range: NSRange(annotation.range, in: self))
        }
        return att
    }
    
    
    public func cleanupFurigana(base:String)->String{
        
        let hiraganaRanges=base.hiraganaRanges
        var transliteration=self
        
        for hiraganaRange in hiraganaRanges{
            switch hiraganaRange {
            case _ where hiraganaRange.upperBound == base.endIndex:
                let trailingDistance=base.distance(from: base.endIndex, to: hiraganaRange.lowerBound)
                
                let transliterationEnd=transliteration.index(transliteration.endIndex, offsetBy: trailingDistance)
                let newTransliterationRange=transliterationEnd..<transliteration.endIndex
                transliteration.replaceSubrange(newTransliterationRange, with: "　")
                
            case _ where hiraganaRange.lowerBound == base.startIndex:
                let leadingDistance=base.distance(from: base.startIndex, to: hiraganaRange.upperBound)
                
                let transliterationStart=transliteration.index(transliteration.startIndex, offsetBy: leadingDistance)
                let newTransliterationRange=transliteration.startIndex..<transliterationStart
                transliteration.replaceSubrange(newTransliterationRange, with: "　")
                
            default:
                let detectedCenterHiragana=base[hiraganaRange]
                transliteration = transliteration.replacingOccurrences(of: detectedCenterHiragana, with: "　")
            }
            
        }
        return transliteration
    }
    
}
