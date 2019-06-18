//
//  UIView_Extension.swift
//  MazeGenerator
//
//  Created by Hoang Luong on 13/6/19.
//  Copyright © 2019 Hoang Luong. All rights reserved.
//

import UIKit

extension UIView {
    
    class func getAllSubviews<T: UIView>(from parentView: UIView) -> [T] {
        return parentView.subviews.flatMap {subView -> [T] in
            var result = getAllSubviews(from: subView) as [T]
            if let view = subView as? T { result.append(view) }
            return result
        }
    }
    
    func getAllSubviews<T: UIView>() -> [T] {
        return UIView.getAllSubviews(from: self) as [T]
    }
    
}
