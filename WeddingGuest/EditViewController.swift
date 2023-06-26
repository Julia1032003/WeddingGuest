//
//  EditViewController.swift
//  WeddingGuest
//
//  Created by JuliaWang on 2023/7/5.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate  {
    
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var cakeLabel: UILabel!
    
    @IBOutlet weak var giftTextField: UITextField!
    @IBOutlet weak var deskTextField: UITextField!
    @IBOutlet weak var peopleTextField: UITextField!
    
    @IBOutlet weak var cakeButton: UIButton!
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    //Move Up Down
    var keyInTextField: UITextField!
    //暫存 View 的範圍
    var rect: CGRect?
    
    var model = wViewModel()
    var guestCheckIn = guestCheckInData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.text = self.guestCheckIn.name
        categoryLabel.text = self.guestCheckIn.category
        kindLabel.text = self.guestCheckIn.kind
        cakeLabel.text = self.guestCheckIn.brideCake
        giftTextField.text = self.guestCheckIn.gift
        deskTextField.text = self.guestCheckIn.desk
        peopleTextField.text = self.guestCheckIn.people
        
        giftTextField.delegate = self
        deskTextField.delegate = self
        peopleTextField.delegate = self
        
        giftTextField.returnKeyType = .done
        giftTextField.keyboardType = .numberPad
        giftTextField.setNumberKeyboardReturn(target: self)
        deskTextField.returnKeyType = .done
        peopleTextField.returnKeyType = .done
        peopleTextField.keyboardType = .numberPad
        peopleTextField.setNumberKeyboardReturn(target: self)
        
        attendBtn()
        cakeBtn()
        
        if (self.guestCheckIn.attend == "是"){
            attendButton.isSelected = true
        }else{
            attendButton.isSelected = false
        }
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        self.initInfo()
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /*------------------------------畫面處理及初始化------------------------------*/
    //初始值
    func initInfo(){
        
        self.guestCheckIn = guestCheckInData.init()
        self.nameLabel.text = ""
        self.cakeLabel.text = ""
        self.kindLabel.text = ""
        self.cakeLabel.text = ""
        self.giftTextField.text = ""
        self.deskTextField.text = ""
        self.peopleTextField.text = ""
        cakeBtn()
        attendBtn()
        attendButton.isSelected = false
    }
    
    //喜餅按鈕
    func cakeBtn(){
        cakeButton.showsMenuAsPrimaryAction = true
        cakeButton.changesSelectionAsPrimaryAction = true
        
        var actions: [UIAction] = []
        let cakeKinds:[String] = ["未領取","已領取","鐵盒餅乾","無喜餅"]
        
        for c in cakeKinds{
            let action = UIAction(title:c, handler: {action in
                
                self.guestCheckIn.brideCake = c
            })
            actions.append(action)
        }
        
        cakeButton.menu = UIMenu(children:actions)

    }
    
    //出席按鈕
    func attendBtn(){
        
        attendButton.changesSelectionAsPrimaryAction = true
        attendButton.configurationUpdateHandler = { attendButton in
            var config = attendButton.configuration
            config?.image = UIImage(systemName: "\(attendButton.isSelected ? "checkmark.":"")rectangle")
            attendButton.configuration = config
            self.guestCheckIn.attend = "是"
        }

    }
    
    //wait activity
    func activityIndicator(style: UIActivityIndicatorView.Style = .medium, frame: CGRect? = nil, center: CGPoint? = nil) -> UIActivityIndicatorView {
      
        let activityIndicatorView = UIActivityIndicatorView(style: style)
        
        if let frame = frame {
            activityIndicatorView.frame = frame
        }
        
        if let center = center {
            activityIndicatorView.center = center
        }
        
        return activityIndicatorView
    }
    
    //textField delagate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Set-Move Up and Down KeyInTextField for keyboard over check
        keyInTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //Set-end of edit , resignResponder
        textField.resignFirstResponder()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
      
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Set-Return, resignResponder
        textField.resignFirstResponder()
        
        return true
    }
    
    //監聽 鍵盤顯示/隱藏 事件
    func keyboardNotifications(){
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        
        //將 View 原始範圍儲存
        rect = view.bounds
    }
    
    @objc func keyboardWillShow(note: NSNotification) {
        if keyInTextField == nil {
            return
        }
        
        let userInfo = note.userInfo!
        //取得鍵盤尺寸
        let keyboard = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        //取得焦點輸入框的位置
        //let origin = (keyInTextField?.frame.origin)!
        if let stackView = keyInTextField.superview as? UIStackView {
            // Get the frame of the stackView in its parent's coordinate system
            let stackViewFrameInSuperview = stackView.frame
            
            // Convert the stackView's frame to self.view's coordinate system
            let stackViewFrameInSelfView = self.view.convert(stackViewFrameInSuperview, from: stackView.superview)
            
            // Get the y coordinate of the stackView
            let stackViewY = stackViewFrameInSelfView.origin.y
            
            //取得焦點輸入框的高度
            let height = (keyInTextField?.frame.size.height)!
            //計算輸入框最底部Y座標，原Y座標為上方位置，需要加上高度
            let targetY = stackViewY + height
            //計算扣除鍵盤高度後的可視高度
            let visibleRectWithoutKeyboard = self.view.bounds.size.height - keyboard.height
            
            //如果輸入框Y座標在可視高度外，表示鍵盤已擋住輸入框
            if targetY >= visibleRectWithoutKeyboard {
                var rect = self.rect!
                //計算上移距離，若想要鍵盤貼齊輸入框底部，可將 + 5 部分移除
                rect.origin.y -= (targetY - visibleRectWithoutKeyboard) + 5

                UIView.animate(
                    withDuration: duration,
                    animations: { () -> Void in
                        self.view.frame = rect
                    }
                )
            }
            
        }
    }
    
    @objc func keyboardWillHide(note: NSNotification) {
          //鍵盤隱藏時將畫面下移回原樣
          let keyboardAnimationDetail = note.userInfo as! [String: AnyObject]
          let duration = TimeInterval(truncating: keyboardAnimationDetail[UIResponder.keyboardAnimationDurationUserInfoKey]! as! NSNumber)
          
          UIView.animate(
              withDuration: duration,
              animations: { () -> Void in
                  self.view.frame = self.view.frame.offsetBy(dx: 0, dy: -self.view.frame.origin.y)
              }
          )
      }

    //點空白處收鍵盤
    func addTapGesture(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    @objc private func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    
    /*------------------------------資料送出及處理------------------------------*/
    //檢查欄位
    func checkInfo()->String{
        
        var msg = ""
    
        //檢核禮金
        let gift = giftTextField.text?.trimmingCharacters(in: .whitespaces)
        if (gift == ""){
            msg = "請輸入禮金欄位(如未收則請輸入零！)"
        }else{
            let checkNum = model.isNumericString(gift!)
            if (checkNum){
                self.guestCheckIn.gift = gift!
            }else{
                msg = "請輸入數字！"
            }
        }
        
        //檢核桌次
        let desk = deskTextField.text?.trimmingCharacters(in: .whitespaces)
        if (desk == ""){
            msg = "請輸入桌次"
        }else{
            self.guestCheckIn.desk = desk!
        }
        
        //檢核出席
        if (attendButton.isSelected == true){
            self.guestCheckIn.attend = "是"
        }else{
            self.guestCheckIn.attend = "否"
        }
        
        //檢核人數
        let peo = peopleTextField.text?.trimmingCharacters(in: .whitespaces)
        if (peo == ""){
            msg = "請輸入人數欄位！"
        }else{
            let checkNum = model.isNumericString(peo!)
            if (checkNum){
                self.guestCheckIn.people = peo!
            }else{
                msg = "請輸入數字！"
            }
        }
        
        return msg
    }
    
    
    @IBAction func editSendBtn(_ sender: Any) {
        
        let indicatorView = self.activityIndicator(style: .medium, center: self.view.center)
        self.view.addSubview(indicatorView)
        indicatorView.startAnimating()

        let check = checkInfo()
        if (check == ""){

            DispatchQueue.main.async(execute: { [self] in

                let insertMsg = self.model.modifyGuestInfo(guestCheckIn)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){

                    self.dismiss(animated: true, completion: nil)
                    indicatorView.stopAnimating()
                    
                    let alert = UIAlertController(title: "報到賓客", message: insertMsg , preferredStyle: .alert)

                    let confirm = UIAlertAction(title: "確認", style: .default, handler: { action in
                        self.initInfo()
                        self.navigationController?.popToRootViewController(animated: true)
                    })

                    alert.addAction(confirm)

                    //Set-alertController
                    self.present(alert, animated: true, completion: nil)

                }

            })

        }else{

            //Set-main queue
            DispatchQueue.main.async(execute: {
                //Set-Close waiting
                self.dismiss(animated: true, completion: nil)
                indicatorView.stopAnimating()
                
                let alert = UIAlertController(title:"報到賓客資料", message: check, preferredStyle: .alert)
                let confirm = UIAlertAction(title: "確認", style: .default, handler: { action in
                    self.navigationController?.popToRootViewController(animated: true)
                })

                alert.addAction(confirm)

                //Set-alertController
                self.present(alert, animated: true, completion: nil)
            })

        }
    }
    
 
}
