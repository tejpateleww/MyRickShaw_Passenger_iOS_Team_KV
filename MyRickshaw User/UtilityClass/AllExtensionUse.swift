//
//  AllExtensionUse.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 05/06/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation


//-------------------------------------------------------------
// MARK: - Double Extension
//-------------------------------------------------------------

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

//-------------------------------------------------------------
// MARK: - UIImage Extension
//-------------------------------------------------------------

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}


//-------------------------------------------------------------
// MARK: - UIApplication Extension
//-------------------------------------------------------------

extension UIApplication {
//    var statusBarView: UIView? {
//        return value(forKey: "statusBar") as? UIView
//    }
}

//-------------------------------------------------------------
// MARK: - UILabel Extension
//-------------------------------------------------------------

extension UILabel {
    func setSizeFont (sizeFont: Double) {
        self.font =  UIFont(name: self.font.fontName, size: CGFloat(sizeFont))!
        self.sizeToFit()
    }
}

//-------------------------------------------------------------
// MARK: - NSMutableAttributedString Extension
//-------------------------------------------------------------

extension NSMutableAttributedString {
    func bold(_ text: String, _ fontSize: CGFloat) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "AvenirNext-Medium", size: fontSize)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
    
    func normal(_ text: String) -> NSMutableAttributedString {
        let normal = NSAttributedString(string: text)
        append(normal)
        
        return self
    }
}

//-------------------------------------------------------------
// MARK: - UIView Extension
//-------------------------------------------------------------

extension UIView {
    
    func dropShadowToCardView(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func giveShadowToBottomView(item: UIView, shadowColor: UIColor ) {
        
        item.layer.shadowColor = shadowColor.cgColor
        item.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        item.layer.shadowOpacity = 1.0
        item.layer.shadowRadius = 0.0
        item.layer.masksToBounds = false
    }
}


//-------------------------------------------------------------
// MARK: - String Extension
//-------------------------------------------------------------

extension String {
    
    // formatting text for currency textField
    func currencyInputFormatting() -> String {
        
        var number: NSNumber!
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        //        formatter.numberStyle = .currencyAccounting
        formatter.currencySymbol = "\(currencySign)"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        var amountWithPrefix = self
        
        // remove from String: "$", ".", ","
        let regex = try! NSRegularExpression(pattern: "[^0-9]", options: .caseInsensitive)
        amountWithPrefix = regex.stringByReplacingMatches(in: amountWithPrefix, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.characters.count), withTemplate: "")
        
        let double = (amountWithPrefix as NSString).doubleValue
        number = NSNumber(value: (double / 100))
        
        // if first number is 0 or all numbers were deleted
        guard number != 0 as NSNumber else {
            return ""
        }
        
        print("Amount : \(number)")
        
        return formatter.string(from: number)!
    }
}


extension UILabel {
    func addCharactersSpacing(_ value: CGFloat = 1.15) {
        if let textString = text {
            let attrs: [NSAttributedString.Key : Any] = [.kern: value]
            attributedText = NSAttributedString(string: textString, attributes: attrs)
        }
    }
}


extension UIViewController {
    
    /// Uniq Data
    func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
    
}

extension Array where Element: Equatable {
    mutating func removeDuplicates() {
        var result = [Element]()
        for value in self {
            if !result.contains(value) {
                result.append(value)
            }
        }
        self = result
    }
}

func delay(_ delay: Double, block:@escaping ()->())
{
    let nSecDispatchTime = DispatchTime.now() + delay;
    let queue = DispatchQueue.main
    
    queue.asyncAfter(deadline: nSecDispatchTime, execute: block)
}


/*
//-------------------------------------------------------------
// MARK: - Check is Present or not
//-------------------------------------------------------------

extension UIViewController {
    
    func isModal() -> Bool {
        if (presentingViewController != nil) {
            return true
        }
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        if (tabBarController?.presentingViewController is UITabBarController) {
            return true
        }
        return false
    }
    
    func alertCustom(message: String, title: String = "") {
        if (isModal()) {
            dismiss(animated: true, completion: nil)
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}
*/

