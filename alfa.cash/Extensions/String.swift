//
//  String.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 14.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import RxLocalizer
import TrustWalletCore
import BigInt
import CryptoKit

extension String {

    func hexColor () -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    func localized() -> String {
        if NSLocalizedString(self, comment: "") == self {
            //return english text if there no translation
            guard let fallbackBundlePath = Bundle.main.path(forResource: "en", ofType: "lproj"),
            let fallbackBundle = Bundle(path: fallbackBundlePath) else { return self }

            let fallbackString = fallbackBundle.localizedString(forKey: self, value: "", table: nil)
            return Bundle.main.localizedString(forKey: self, value: fallbackString, table: nil)
        }
        return NSLocalizedString(self, comment: "")
    }
    
    func headerViewWithTitle() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 51))
        let label = ACLabel()//frame: CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 40, height: 32))
        label.numberOfLines = 0
        label.textColor = UIColor.kHeaderColor
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        label.setText(self)
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        view.trailingAnchor.constraint(equalTo: label.trailingAnchor, constant: 20).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        return view
    }
    
    func headerThemedViewWithTitle() -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 51))
        let label = HeaderLabel(frame: CGRect(x: 30, y: 10, width: UIScreen.main.bounds.width - 40, height: 16))
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.setText(self)
        
        view.addSubview(label)
        return view
    }
    
    func removeExtraSpaces() -> String {
        return self.replacingOccurrences(of: "[\\s\n]+", with: " ", options: .regularExpression, range: nil)
    }

    
    //Validation
    
    func handledComaText() -> String {
        if self.contains(",") {
            let newAmount = self.replacingOccurrences(of: ",", with: ".")
            return newAmount
        }
        return self
    }
    
    func handledZerosText() -> String {
        if self.contains(".") {
            let components = self.components(separatedBy: ".")
            if components.count > 2 {
                return self
            }
            if let beforeDot = components.first,
                let afterDot = components.last,
                let roundNumber = Int(beforeDot) {
                    let beforeDotDropped = beforeDot.dropFirstZero()
                    if roundNumber == 0 {
                        if beforeDotDropped.count > 1 {
                            return "0." + afterDot
                        }
                    }
                    return beforeDotDropped + "." + afterDot
                    }
        } else {
            return self.dropFirstZero()
        }
        
        return self
    }
    
    func dropFirstZero() -> String {
        var string = self
        if self.first == "0", self.count > 1 {
            string.remove(at: String.Index(encodedOffset: 0))
            string = string.dropFirstZero()
            return string
        } else {
            return self
        }
    }
    
    func handledFirstZeroText() -> String {
        if let firstChar = self.first,
            firstChar == "." {
            let newAmount = self.replacingOccurrences(of: ".", with: "0.")
            return newAmount
        }
        return self
    }
    
    func handledSecondZeroText() -> String {
        let last = self.last
        var newAmount = self
        newAmount = String(newAmount.dropLast())
        if newAmount.contains("."), last == "." {
            return newAmount
        }
        return self
    }
    
    func handledSecondZeroFiatText() -> String {
        guard self.count > 1, self.first == "0" else { return self }
        let second = self[String.Index(encodedOffset: 1)]
        if second == "0" {
            return String(self.dropLast())
        } else if second == "." {
            return self
        } else {
            return String(self.dropFirst())
        }
    }
    
    func handledLengthText(coin: CoinType) -> String {
        let allowedLength = coin == .ethereum ? 20 : 10
        var newAmount = self
        if newAmount.count > allowedLength {
            newAmount = String(newAmount.dropLast())
        }
        return newAmount
    }
    
    func handledLengthAfterComa() -> String {
        guard self.contains(".") else { return self }
        let allowedLength = 2
        var newString = self
        if let afterComa = self.components(separatedBy: ".").last, !afterComa.isEmpty {
            if afterComa.count > allowedLength {
                newString = String(newString.dropLast())
            }
            return newString
        }
        return self
    }
    
    func handledAmountTFText(coin: CoinType) -> String {
        var validatedAmount = self.handledComaText()
        validatedAmount = validatedAmount.handledFirstZeroText()
        validatedAmount = validatedAmount.handledZerosText()
        validatedAmount = validatedAmount.handledLengthText(coin: coin)
        validatedAmount = validatedAmount.handledSecondZeroText()
        return validatedAmount
    }
    
    func handledFiatAmountTFText() -> String {
        var validatedAmount = self.handledComaText()
        validatedAmount = validatedAmount.handledFirstZeroText()
        validatedAmount = validatedAmount.handledSecondZeroFiatText()
        validatedAmount = validatedAmount.handledZerosText()
        validatedAmount = validatedAmount.handledLengthAfterComa()
        validatedAmount = validatedAmount.handledSecondZeroText()
        return validatedAmount
    }
    
    func isNameValid() -> Bool {
        let nameRegex = "^[a-zA-Z0-9_]{0,20}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self)
    }
    
    func isAddressValid() -> Bool {
        let addressRegex = "^[a-zA-Z0-9:@_]{0,100}$"
        return NSPredicate(format: "SELF MATCHES %@", addressRegex).evaluate(with: self)
    }
    
    func isAmountValid() -> Bool {
        let amountRegex = "^(?:|0|[1-9]\\d*)(?:\\.\\d*)?$"
        return NSPredicate(format: "SELF MATCHES %@", amountRegex).evaluate(with: self)
    }
    
    func isAmountValidSigns() -> Bool {
        let amountRegex = "^[0-9.]*$"
        return NSPredicate(format: "SELF MATCHES %@", amountRegex).evaluate(with: self)
    }
    
    func isEosAccountValid() -> Bool {
        let accountRegex = "^[a-z1-5]{0,12}$"
        return NSPredicate(format: "SELF MATCHES %@", accountRegex).evaluate(with: self)
    }
    
    func isMemoValid(regex: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: self)
    }
    
    func noPrefix() -> String {
        return String(self.dropFirst(2))
    }
    
    func toByteStringAmount() -> Data {
        return BigInt(self.noPrefix(), radix: 16)!.serialize()!
    }
    
    func toInt64() -> Int64? {
        return Int64(self)
    }
    
    func toInt32() -> Int32? {
        return Int32(self)
    }
    
    public var reversedData: Data? {
        return Data(hex: self).map { Data($0.reversed()) }
    }
    
    func key() -> SymmetricKey {
      // Create a SHA256 hash from the provided password
      let hash = SHA256.hash(data: self.data(using: .utf8)!)
      // Convert the SHA256 to a string. This will be a 64 byte string
      let hashString = hash.map { String(format: "%02hhx", $0) }.joined()
      // Convert to 32 bytes
      let subString = String(hashString.prefix(32))
      // Convert the substring to data
      let keyData = subString.data(using: .utf8)!

      // Create the key use keyData as the seed
      return SymmetricKey(data: keyData)
    }
    
    func toDateWith(format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        let date = dateFormatter.date(from: self)
        return date
    }
}
