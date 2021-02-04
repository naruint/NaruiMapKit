//
//  UITextField+extension.swift
//  lmhs
//
//  Created by Changyeol Seo on 2020/12/16.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

extension UITextField {
    func makeConfirmToolBar(title:String, buttonTitle:String, target:Any?, action:Selector?, height:CGFloat = 40) {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: target, action: action)
        barButton.setTitleTextAttributes([.font:UIFont.boldSystemFont(ofSize: 15)], for: .normal)
        let title = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        title.setTitleTextAttributes([.font:UIFont.boldSystemFont(ofSize: 15)], for: .normal)
        title.isEnabled = false        
        let toolbar = UIToolbar()
        toolbar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        toolbar.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        if #available(iOS 13.0, *) {
            toolbar.tintColor = UIColor.lightText
            toolbar.backgroundColor = UIColor.systemGroupedBackground
        }

        
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        if #available(iOS 14.0, *) {
            toolbar.setItems([title,.flexibleSpace(), barButton], animated: true)
        } else {
            toolbar.setItems([title,flexibleSpace, barButton], animated: true)
        }
        inputAccessoryView = toolbar
    }
}
