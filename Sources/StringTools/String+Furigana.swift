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
    public func furiganaAttributedString(furigana:String, kanjiOnly:Bool = true, useRomaji:Bool = false) -> NSAttributedString{
        let hiraganaRanges=self.hiraganaRanges
        var transliteration=furigana
        var range=self.startIndex..<self.endIndex
        for hiraganaRange in hiraganaRanges{
            switch hiraganaRange {
            case _ where hiraganaRange.upperBound == self.endIndex:
                let trailingDistance=self.distance(from: self.endIndex, to: hiraganaRange.lowerBound)
                let newEndIndex=self.index(range.upperBound, offsetBy: trailingDistance)
                range=range.lowerBound..<newEndIndex
                let transliterationEnd=transliteration.index(transliteration.endIndex, offsetBy: trailingDistance)
                let newTransliterationRange=transliteration.startIndex..<transliterationEnd
                let t2=transliteration[newTransliterationRange]
                transliteration=String(t2)
            case _ where hiraganaRange.lowerBound == self.startIndex:
                let leadingDistance=self.distance(from: self.startIndex, to: hiraganaRange.upperBound)
                let newStartIndex=self.index(range.lowerBound, offsetBy: leadingDistance)// wrong?
                range=newStartIndex..<range.upperBound
                let transliterationStart=transliteration.index(transliteration.startIndex, offsetBy: leadingDistance)
                let newTransliterationRange=transliterationStart..<transliteration.endIndex
                let t2=transliteration[newTransliterationRange]
                transliteration=String(t2)
            default:
//                let leadingDistance=self.distance(from: self.startIndex, to: hiraganaRange.lowerBound)
//                let trailingDistance=self.distance(from: self.endIndex, to: hiraganaRange.upperBound)
//                let transliterationStart=transliteration.index(transliteration.startIndex, offsetBy: leadingDistance)
//                let transliterationEnd=transliteration.index(transliteration.endIndex, offsetBy: trailingDistance)
//                let newTransliterationRange=transliterationStart..<transliterationEnd
//                let length=self.distance(from: hiraganaRange.lowerBound, to: hiraganaRange.upperBound)
//                let replacementString=String(repeatElement("　", count: length))
//                transliteration.replaceSubrange(newTransliterationRange, with: replacementString)
                let detectedCenterHiragana=self[hiraganaRange]
                transliteration = transliteration.replacingOccurrences(of: detectedCenterHiragana, with: "　")
            }
        }
        
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
    
}
