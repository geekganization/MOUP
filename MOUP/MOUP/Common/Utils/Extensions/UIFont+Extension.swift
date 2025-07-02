//
//  UIFont+Extension.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import UIKit

extension UIFont {
    static func headBold(_ size: CGFloat) -> Self {
        return UIFont(name: "Pretendard-Bold", size: size) as! Self
    }
    
    static func bodyMedium(_ size: CGFloat) -> Self {
        return UIFont(name: "Pretendard-Medium", size: size) as! Self
    }
    
    static func buttonSemibold(_ size: CGFloat) -> Self {
        return UIFont(name: "Pretendard-SemiBold", size: size) as! Self
    }
    
    static func fieldsRegular(_ size: CGFloat) -> Self {
        return UIFont(name: "Pretendard-Regular", size: size) as! Self
    }
}
