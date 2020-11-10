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

