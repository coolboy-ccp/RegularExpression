//
//  Reg.swift
//  RegExpression
//
//  Created by 储诚鹏 on 2019/12/11.
//  Copyright © 2019 储诚鹏. All rights reserved.
//

import UIKit


enum MobileRegType {
    case cm //移动
    case cu //联通
    case ct //电信
    case all
}

extension MobileRegType {
    var reg: String {
        switch self {
        case .cm:
            return "^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478]|9[8])\\d{8}$)|(^1705\\d{7}$"
        case .cu:
            return "^1(3[0-2]|4[5]|5[56]|66|7[56]|8[56])\\d{8}$)|(^1709\\d{7}$"
        case .ct:
            return "^1(33|53|77|8[019]|99)\\d{8}$)|(^1700\\d{7}$"
        case .all:
            return "^1(3[0-9]|4[57]|5[0-35-9]|6[6]|7[05-8]|8[0-9]|9[89])\\d{8}$"
        }
    }
}

enum Reg {
    case ID //中国大陆身份证
    case mobile(_ type: MobileRegType) //手机号
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
            let month = "(0[1-9]{1}|1[1-2]{1})"
            let day = "(0[1-9]{1}|[1-2]{1}[0-9]{1}|3{1}[0-1]{1})" //每月以31天考虑
            return "\(area)\(year)\(month)\(day)(\\d{3})[xX0-9]{1}"
        case .mobile(let type):
            return type.reg
        case .mail:
            return "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        case .passprot:
            return "^1[45][0-9]{7}|([P|p|S|s]\\d{7})|([S|s|G|g]\\d{8})|([Gg|Tt|Ss|Ll|Qq|Dd|Aa|Ff]\\d{8})|([H|h|M|m]\\d{8，10})$"
        case .carID:
            return "^[\\u4e00-\\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\\u4e00-\\u9fa5]$"
        case .bankID:
            return ""
        case .num(let n):
            return "\\d{\(n)}"
        case .char(let n):
            return "[a-zA-Z]{\(n)}"
        case .numChar(let n):
            return "[a-zA-Z0-9]{\(n)}"

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
        
        /*
         1、将前面的身份证号码17位数分别乘以不同的系数。从第一位到第十七位的系数分别为：7－9－10－5－8－4－2－1－6－3－7－9－10－5－8－4－2。
         2、将这17位数字和系数相乘的结果相加。
         3、用加出来和除以11，看余数是多少？
     4、余数只可能有0－1－2－3－4－5－6－7－8－9－10这11个数字。其分别对应的最后一位身份证的号码为1－0－X－9－8－7－6－5－4－3－2。(即余数0对应1，余数1对应0，余数2对应X...)
         5、通过上面得知如果余数是3，就会在身份证的第18位数字上出现的是9。如果对应的数字是2，身份证的最后一位号码就是罗马数字x。
         */
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
