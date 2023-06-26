//
//  wExten.swift
//  WeddingGuest
//
//  Created by JuliaWang on 2023/7/5.
//

import Foundation
import UIKit

extension UITextField {
    
    //extension NumberKeyboard return
    func setNumberKeyboardReturn(target: Any) {
        
        let appWidth = Float(UIScreen.main.bounds.width)
        let accessoryView = UIToolbar(
            frame: CGRect(x: 0, y: 0, width: CGFloat(appWidth), height: CGFloat(0.1 * appWidth)))
        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil)
        let done = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(selectDoneButton))

        accessoryView.items = [space, done, space]
        self.inputAccessoryView = accessoryView
    }
    
    @objc func selectDoneButton(){
        self.resignFirstResponder()
    }
    
    //extension DatePicker
    func setInputViewDatePicker(target: Any, selector: Selector) {
        // Create a UIDatePicker object and assign to inputView
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = .date
        
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        self.inputView = datePicker
        
        // Create a toolbar and assign it to inputAccessoryView
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: nil, action: #selector(tapCancel))
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: target, action: selector)
        toolBar.setItems([cancel, flexible, barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc func tapCancel() {
        self.resignFirstResponder()
    }
}
