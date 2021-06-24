//
//  FancyTextView.swift
//  Accord
//
//  Created by evelyn on 2021-06-21.
//

import Foundation
import SwiftUI

struct FancyTextView: View {
    @Binding var text: String
    var body: some View {
        HStack {
            if let splitText = text.components(separatedBy: " ") {
                HStack(spacing: 0) {
                    getTextArray(splitText: splitText).reduce(Text(""), +)
                }
            }
        }
    }
}


public func getTextArray(splitText: [String]) -> [Text] {
    var textArray: [Text] = []
    for text in splitText {
        if (text.prefix(2) == "<:" || text.prefix(2) == #"\<:"# || text.prefix(2) == "<a:") && text.suffix(1) == ">" {
            for id in text.capturedGroups(withRegex: #"<:\w+:(\d+)>"#) {
                if let _ = URL(string: "https://cdn.discordapp.com/emojis/\(id).png") {
                    textArray.append(Text("\(Image(nsImage: resize(image: NSImage(data: sendRequest(url: "https://cdn.discordapp.com/emojis/\(id).png") ?? Data())!, w: 15, h: 15)))"))
                }
            }
        } else {
            if #available(macOS 12.0, *) {
                textArray.append(Text(try! AttributedString(markdown: "\(text)")))
                textArray.append(Text(" "))
            } else {
                textArray.append(Text("\(text) "))
            }
        }
    }
    return textArray
}


public func matches(for regex: String, in text: String) -> [String] {

    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex \(error.localizedDescription)")
        return []
    }
}

public extension String {
    func capturedGroups(withRegex pattern: String) -> [String] {
        var results = [String]()

        var regex: NSRegularExpression
        do {
            regex = try NSRegularExpression(pattern: pattern, options: [] )
        } catch {
            return results
        }
        let matches = regex.matches(in: self, options: [], range: NSRange(location:0, length: self.count))

        guard let match = matches.first else { return results }

        let lastRangeIndex = match.numberOfRanges - 1
        guard lastRangeIndex >= 1 else { return results }
        for i in 1...lastRangeIndex {
            let capturedGroupIndex = match.range(at: i)
            let matchedString = (self as NSString).substring(with: capturedGroupIndex)
            results.append(matchedString)
        }

        return results
    }
    
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
    
    func indexInt(of char: Character) -> Int? {
        return firstIndex(of: char)?.utf16Offset(in: self)
    }
}
