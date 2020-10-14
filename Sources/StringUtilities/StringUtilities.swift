//
//  StringExtensions.swift
//
//  Created by TJ Sartain on 5/16/17.
//  Copyright © 2017 iTrinity, Inc. All rights reserved.
//

import UIKit

public enum HorizontalAlignment
{
    case Left
    case Center
    case Right
    case Justified
    var name: String {
             if self == .Left   { return "Left"      }
        else if self == .Center { return "Center"    }
        else if self == .Right  { return "Right"     }
        else                    { return "Justified" }
    }
}

public enum VerticalAlignment
{
    case Top
    case Middle
    case Bottom
    var name: String {
             if self == .Top    { return "Top"    }
        else if self == .Middle { return "Middle" }
        else                    { return "Bottom" }
    }
}

public let SMALL_WORDS = ["a", "an", "and", "the"]

extension NSMutableAttributedString
{
    public func appending(_ more: NSAttributedString, newLine: Bool? = false) -> NSMutableAttributedString
    {
        let copy = self
        if newLine! {
            copy.append(NSMutableAttributedString(string: "\n"))
        }
        copy.append(more)
        return copy
    }
}

extension String
{
    public func stringByAddingPercentEncodingForRFC3986() -> String?
    {
        let unreserved = ".-_~"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return self.addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
    public func toDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    public func date(_ fmt: String? = "yyyy-MM-dd hh:mm:ss a") -> Date?
    {
        var formats = ["yyyy-MM-dd hh:mm a",
                       "yyyy-MM-dd hh:mm",
                       "yyyy-MM-dd",
                       "MM/dd/yyyy hh:mm",
                       "MM/dd/yyyy",
                       "M/d/yyyy hh:mm:ss a",
                       "M/d/yyyy hh:mm",
                       "M/d/yyyy"]
        if let fmt = fmt, fmt.isNotEmpty() {
            formats.insert(fmt, at: 0)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(name: "UTC") as TimeZone?
        dateFormatter.isLenient = true
        
        for fmt in formats {
            dateFormatter.dateFormat = fmt
            if let date = dateFormatter.date(from: self) {
                // make sure it reciprocates
                if dateFormatter.string(from: date) == self {
                    return date
                }
            }
        }
        return nil
    }
    
    public func size(withFont font: UIFont) -> CGSize
    {
        return self.boundingRect(with: CGSize(width: Double.greatestFiniteMagnitude,
                                              height: Double.greatestFiniteMagnitude),
                                 options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                 attributes: [NSAttributedString.Key.font: font],
                                 context: nil).size
    }
    
//    var uiColor: UIColor {
//        return colorFrom(self)
//    }
    
    public var isNumber: Bool {
        return Double(self) != nil
    }
    
    public func dpad(_ d: Int) -> String
    {
        var pad = d + 1
        if let dp = self.firstIndex(of: ".") {
            let p = self.distance(from: startIndex, to: dp)
            pad = pad + p - self.count
        }
        return self + "                       ".prefix(pad)
    }
    
    public func dpad(_ d: Int, pad: String) -> String
    {
        var newString = self
        var n = d
        if let i = self.firstIndex(of: ".") {
            let dp = self.distance(from: startIndex, to: i)
            n = n + 1 + dp - self.count
        } else if d > 0 {
            newString.append(".")
        }
        if n > 0 {
            for _ in 0..<n {
                newString.append(pad)
            }
        }
        return newString
    }
    
    public var length : Int
    {
        return self.count
    }
    
    public func equals(_ string: String) -> Bool
    {
        return caseInsensitiveCompare(string) == .orderedSame
    }
    
    public func allDigits() -> Bool
    {
        if self.count > 0 {
            for i in 0..<self.count {
                if !("0123456789".contains(self[i..<i+1])) {
                    return false
                }
            }
            return true
        }
        return false
    }
    
    var trim : String
    {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func trim(_ chars: String) -> String
    {
        let set = CharacterSet(charactersIn: chars)
        return self.trimmingCharacters(in: set)
    }
    
    public func isNotEmpty() -> Bool
    {
        let str = self.trimmingCharacters(in: .whitespacesAndNewlines)
        let empty = ["nil", "<null>", "-1", ""].contains(str)
        return !empty
    }
    
    public func removeDateWord() -> String
    {
        return removeWord("DATE")
    }
    
    public func removeWord(_ word: String?) -> String
    {
        if let word = word {
            let sansWord = self.replacingOccurrences(of: word,
                                                     with: "",
                                                     options: .caseInsensitive,
                                                     range: self.range(of: self))
            return sansWord.trim
        }
        return self
    }
    
    public func removeSpaces() -> String
    {
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    mutating public func withoutSpaces()
    {
        self = self.replacingOccurrences(of: " ", with: "")
    }
    
    public func replace(_ this: String, with that: String) -> String
    {
        return self.replacingOccurrences(of: this, with: that)
    }
    
    mutating public func replacing(_ this: String, with that: String)
    {
        self = self.replacingOccurrences(of: this, with: that)
    }
    
    public func includes(_ this: String, options: NSString.CompareOptions? = .caseInsensitive) -> Bool
    {
        return self.range(of: this, options: options!) != nil
    }
    
    public func pluralize(_ list: [Any]) -> String
    {
        return pluralize(with: "s", basedOn: list)
    }
    
    public func pluralize(with suffix: String, basedOn list: [Any]) -> String
    {
        return pluralize(with: suffix, list.count != 1)
    }
    
    public func pluralize(with suffix: String? = "s", _ yesOrNo: Bool? = true) -> String
    {
        if yesOrNo! {
            return self + suffix!
        }
        return self
    }
    
    public func isAllCaps() -> Bool
    {
        let set = CharacterSet.uppercaseLetters
        for character in self {
            if character != " ", let scala = UnicodeScalar(String(character)) {
                if !set.contains(scala) {
                    return false
                }
            }
        }
        return true
    }
    
    public func nameCase() -> String
    {
        if self.length > 2 {
            let m = "\(self[0])"
            let c = "\(self[1])"
            if m.equals("m"), c.equals("c") {
                return "Mc" + "\(self[2])".uppercased() + "\(self[3..<self.length])".titleCase()
            } else if m.equals("o"), c.equals("'") {
                return "O'" + "\(self[2])".uppercased() + "\(self[3..<self.length])".titleCase()
            }
        }
        return self
    }
    
    public func titleCase() -> String
    {
        var words = self.lowercased().split(separator: " ").map({ String($0) })
        words[0] = words[0].capitalized
        for i in 1 ..< words.count {
            if !SMALL_WORDS.contains(words[i]) {
                words[i] = words[i].capitalized
            }
        }
        return words.joined(separator: " ")
    }
    
    public func sentenceCase() -> String
    {
        var words = self.lowercased().split(separator: " ").map({ String($0) })
        words[0] = words[0].capitalized
        return words.joined(separator: " ")
    }
    
    public func draw(at pt: CGPoint,
              font: UIFont? = UIFont.systemFont(ofSize: 12),
              color: UIColor? = .black,
              align: HorizontalAlignment? = .Center,
              vAlign: VerticalAlignment? = .Middle)
    {
        let attributes: [NSAttributedString.Key : Any] = [.font: font!,
                                                          .foregroundColor: color!]
        
        let size = self.boundingRect(with: CGSize(width: 0, height: 0),
                                     options: [ .usesLineFragmentOrigin ],
                                     attributes: [ .font: font! ],
                                     context: nil).size
        var x = pt.x
        var y = pt.y
        if align == .Center {
            x -= (size.width / 2)
        } else if align == .Right {
            x -= size.width
        }
        if vAlign == .Middle {
            y -= (size.height / 2)
        } else if  vAlign == .Bottom {
            y -= size.height
        }
        let rect = CGRect(x: x, y: y, width: size.width, height: size.height)
        draw(in: rect, withAttributes: attributes)
    }
    
    public func asLabel(_ size: CGFloat? = 13, _ color: UIColor? = .lightGray) -> NSMutableAttributedString
    {
        attr(bold: true, size!, color!)
    }
    
    public func asValue(_ size: CGFloat? = 13, _ color: UIColor? = .gray) -> NSMutableAttributedString
    {
        attr(bold: false, size!, color!)
    }
    
    public func font(ofSize fontSize: CGFloat, bold: Bool? = false, italic: Bool? = false) -> UIFont
    {
        if bold! {
            if italic! {
                return UIFont(name: "Arial-BoldItalicMT", size: fontSize)!
            } else {
                return UIFont(name: "Arial-BoldMT", size: fontSize)!
            }
        } else if italic! {
            return UIFont(name: "Arial-ItalicMT", size: fontSize)!
        } else {
            return UIFont(name: "ArialMT", size: fontSize)!
        }
    }
    
    public func attr(bold: Bool, _ size: CGFloat, _ color: UIColor) -> NSMutableAttributedString
    {
        NSMutableAttributedString(string: self,
                                  attributes: [.font: font(ofSize: size, bold: bold),
                                               .foregroundColor: color])
    }
    
    public func attr(size: CGFloat? = 13,
              bold: Bool? = true,
              color: UIColor? = .black,
              strokeColor: UIColor? = .white,
              strokeWidth: CGFloat? = 0) -> NSMutableAttributedString
    {
        NSMutableAttributedString(string: self,
                                  attributes: [.font: font(ofSize: size!, bold: bold!),
                                               .foregroundColor: color!,
                                               .strokeColor: strokeColor!,
                                               .strokeWidth: strokeWidth!])
    }
    
    public func passesRegex(_ regExPattern: String) -> Bool
    {
        let passes = NSPredicate(format: "SELF MATCHES %@", regExPattern).evaluate(with: self)
        return passes
    }
    
    
    // Subscripting
    
    public subscript (i: Int) -> Character
    {
        return self[index(startIndex, offsetBy: i)]
    }
    
    public subscript (bounds: CountableRange<Int>) -> Substring
    {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    
    public subscript (bounds: CountableClosedRange<Int>) -> Substring
    {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    
    public subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring
    {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    
    public subscript (bounds: PartialRangeThrough<Int>) -> Substring
    {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    
    public subscript (bounds: PartialRangeUpTo<Int>) -> Substring
    {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}
