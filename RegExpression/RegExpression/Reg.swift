//
//  Reg.swift
//  RegExpression
//
//  Created by 储诚鹏 on 2019/12/11.
//  Copyright © 2019 储诚鹏. All rights reserved.
//

import UIKit


enum Reg {
    case ID //中国大陆身份证
    case mobile //手机号
    case mail //邮箱
    case url //是否是一个链接
    case passprot //护照
    case carID //车牌号
    case bankID //银行卡
    case num(_ n: Int) //一个长为n的数字, 传-1时不限长度
    case char(_ n: Int) //一个长为n的字符, 传-1时不限长度
    case numChar(_ n: Int) //一个长为n的数字字符, 传-1时不限长度
}

extension Reg {
    var string: String  {
        switch self {
        case .ID:
            let area = "([1-6]{1}\\d{5})"
            let year = "([1-9]{1}\\d{3})"
            let month = "((?:0[1-9]{1})|(?:1[1-2]{1}))"
            let day = "((?:0[1-9]{1})|(?:[1-3]{1}[0-9]{1}))" //每月以31天考虑
            return "\(area)\(year)\(month)\(day)(\\d{3})[xX0-9]{1}"
        case .mobile:
            return ""
        case .mail:
            return ""
        case .passprot:
            return ""
        case .carID:
            return ""
        case .bankID:
            return ""
        case .num(let n):
            return ""
        case .char(let n):
            return ""
        case .numChar(let n):
            return ""
        default:
            return ""
        }
    }
    
    func match(with source: RegSource) -> Bool {
        do {
            let reg = try NSRegularExpression(pattern: string, options: [])
            guard let rlt = reg.firstMatch(in: source.string, options: [], range: NSRange(location: 0, length: source.string.count)) else {
                return false
            }
            return rlt.range.location != NSNotFound
        } catch {
            return false
        }
    }
    
    func matchComponents(with source: RegSource) -> [String]? {
        do {
            let reg = try NSRegularExpression(pattern: Reg.ID.string, options: [])
            guard let rlt = reg.firstMatch(in: source.string, options: [], range: NSRange(location: 0, length: source.string.count)) else {
                return nil
            }
            return (0 ..< rlt.numberOfRanges).compactMap {
                return NSString(string: source.string).substring(with: rlt.range(at: $0))
            }
        } catch  {
            print(error.localizedDescription)
        }
        return nil
    }
}

protocol RegSource {
    var string: String { get }
}

extension String: RegSource {
    var string: String {
        return self
    }
}

extension NSString: RegSource {
    var string: String {
        return String(self)
    }
}

extension String {
    func isID() -> Bool {
        if !Reg.ID.match(with: self) { return false }
        var ratios = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        let rlts = [1, 0, 10, 9, 8, 7, 6, 5, 4, 3, 2]
        let last = self.last!.uppercased() == "X" ? Character("10") : self.last!
        let idx = self.dropLast().reduce(0) { (result, a) -> Int in
            let rlt = result +  Int(String(a))! * ratios.first!
            ratios.removeFirst()
            return rlt
        } % 11
        return last == Character("\(rlts[idx])")
            
    }
}
