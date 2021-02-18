//
//  UITextField+Extensions.swift
//  NaruiMapKit
//
//  Created by Changyeol Seo on 2020/11/09.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

extension UITextField {
    func setDoneInputView(title:String?, image:UIImage? = nil, target:Any?, action:Selector?, animated:Bool = false) {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        if let title = title {
            let btn = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
            toolbar.setItems([btn], animated: animated)
        }
        if let image = image {
            let btn = UIBarButtonItem(image: image, style: .plain, target: target, action: action)
            toolbar.setItems([btn], animated: animated)
        }
        toolbar.sizeToFit()
        inputAccessoryView = toolbar
        
    }
    
    func setRightButtonDownStyle(disposeBag:DisposeBag, onTouchupRightBtn:@escaping(_ sender:UIButton)->Void) {
        let button = UIButton()
//        button.setImage(#imageLiteral(resourceName: "icon24IconArrowDBlack").withRenderingMode(.alwaysTemplate), for: .normal)
        button.setTitle("+", for: .normal)
        button.sizeToFit()
        button.rx.tap.bind { _ in
            onTouchupRightBtn(button)
        }.disposed(by: disposeBag)
        rightView = button
    }
}

extension UITextField {
    func makeConfirmToolBar(title:String, buttonTitle:String, target:Any?, action:Selector?, height:CGFloat = 40) {
        let textAtt:[NSAttributedString.Key : Any] = [
            .font:UIFont.systemFont(ofSize: 15, weight: .bold),
            .foregroundColor:UIColor(named: "toolbarLabel", in: Bundle(for: NaruMapViewController.self), compatibleWith: nil)!
            
        ]
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let barButton = UIBarButtonItem(title: buttonTitle, style: .plain, target: target, action: action)
        
        barButton.setTitleTextAttributes(textAtt, for: .normal)
        barButton.setTitleTextAttributes(textAtt, for: .highlighted)
        
        let title = UIBarButtonItem(title: title, style: .plain, target: nil, action: nil)
        title.setTitleTextAttributes(textAtt, for: .normal)
        title.setTitleTextAttributes(textAtt, for: .highlighted)
        
        let toolbar = UIToolbar()
        toolbar.tintColor =  UIColor(named: "toolbarLabel", in: Bundle(for: NaruMapViewController.self), compatibleWith: nil)
        toolbar.backgroundColor = UIColor(named: "toolbarBG", in: Bundle(for: NaruMapViewController.self), compatibleWith: nil)
        
        toolbar.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        if #available(iOS 14.0, *) {
            toolbar.setItems([title,.flexibleSpace(), barButton], animated: true)
        } else {
            toolbar.setItems([title,flexibleSpace, barButton], animated: true)
        }
        inputAccessoryView = toolbar
    }
}
