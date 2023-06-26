//
//  CheckInViewController.swift
//  WeddingGuest
//
//  Created by JuliaWang on 2023/6/29.
//

import UIKit

class CheckInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var qrcodeButton: UIButton!
    @IBOutlet weak var kindButton: UIButton!
    @IBOutlet weak var categoryButton: UIButton!
    @IBOutlet weak var cakeButton: UIButton!
    @IBOutlet weak var attendButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var giftText: UITextField!
    @IBOutlet weak var desktText: UITextField!
    @IBOutlet weak var peopleText: UITextField!
    
    @IBOutlet weak var categoryQRLabel: UILabel!
    @IBOutlet weak var kindQRLabel: UILabel!
    @IBOutlet weak var cakeQRLabel: UILabel!
    
    //Move Up Down
    var keyInTextField: UITextField!
    //暫存 View 的範圍
    var rect: CGRect?
    
    var model = wViewModel()
    var guestCheckIn = guestCheckInData()
    var guestInfo = [guestInformation]()
   
    override func viewDidLoad() {
        super.viewDidLoad()

        //按鈕圓角設定
        qrcodeButton.layer.cornerRadius = 10.0
        qrcodeButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = 10.0
        sendButton.layer.masksToBounds = true
        categoryButton.layer.cornerRadius = 10.0
        categoryButton.layer.masksToBounds = true
        kindButton.layer.cornerRadius = 10.0
        kindButton.layer.masksToBounds = true
        cakeButton.layer.cornerRadius = 10.0
        cakeButton.layer.masksToBounds = true
        attendButton.layer.cornerRadius = 10.0
        attendButton.layer.masksToBounds = true
        
        //textField set
        nameText.delegate = self
        giftText.delegate = self
        desktText.delegate = self
        peopleText.delegate = self
        
        nameText.returnKeyType = .done
        desktText.returnKeyType = .done
        giftText.returnKeyType = .done
        giftText.keyboardType = .numberPad
        giftText.setNumberKeyboardReturn(target: self)
        peopleText.returnKeyType = .done
        peopleText.keyboardType = .numberPad
        peopleText.setNumberKeyboardReturn(target: self)
        
        
        //鍵盤事件
        keyboardNotifications()
        //點畫面收鍵盤
        addTapGesture()
        
        //初始化
        initInfo()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        //接收選擇好的編號資料
        let notificationName = Notification.Name("GetQrStr")
        NotificationCenter.default.addObserver(self, selector: #selector(getQrcodeStr(noti:)) , name: notificationName, object: nil)
        
        //先載下DB資料
        self.model.getGuestInfo { [weak self] guestInfo in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self?.guestInfo = guestInfo
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.initInfo()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /*------------------------------畫面處理及初始化------------------------------*/
    //初始值
    func initInfo(){
        
        self.guestCheckIn = guestCheckInData.init()
        self.nameText.text = ""
        self.giftText.text = ""
        self.desktText.text = ""
        self.peopleText.text = ""
        
        categoryButton.isHidden = false
        categoryQRLabel.isHidden = true
        kindButton.isHidden = false
        kindQRLabel.isHidden = true
        cakeButton.isHidden = false
        cakeQRLabel.isHidden = true
        
        categoryBtn()
        kindBtn()
        cakeBtn()
        attendBtn()
        attendButton.isSelected = false
    }
   
    //接收到QRCode資料後的處理
    @objc func getQrcodeStr(noti:Notification) {
        
        //name,cateGory,kind,cake,desk
        let qrStr = noti.userInfo!["guestQRStr"] as? String
        if (qrStr != nil){
            
            let info = qrStr?.split(separator: ",")
            
            //name
            guestCheckIn.name = String(info![0])
            nameText.text = guestCheckIn.name
            
            //CateGory
            guestCheckIn.category = String(info![1])
            categoryButton.isHidden = true
            categoryQRLabel.isHidden = false
            categoryQRLabel.text = guestCheckIn.category
            
            //kind
            guestCheckIn.kind = String(info![2])
            kindButton.isHidden = true
            kindQRLabel.isHidden = false
            kindQRLabel.text = guestCheckIn.kind
            
            //cake
            guestCheckIn.brideCake = String(info![3])
            if guestCheckIn.brideCake == "無喜餅"{
                cakeButton.isHidden = true
            }else{
                cakeButton.isHidden = false
            }
            cakeQRLabel.text = guestCheckIn.brideCake
           
            //desk
            guestCheckIn.desk = String(info![4])
            desktText.text = guestCheckIn.desk
            
            //people
            guestCheckIn.people = String(info![5])
            peopleText.text = guestCheckIn.people
            
        }
    }
    
    //Button
    //分類按鈕
    func categoryBtn(){
        categoryButton.showsMenuAsPrimaryAction = true
        categoryButton.changesSelectionAsPrimaryAction = true
        
        var actions: [UIAction] = []
        let allcategory:[String] = ["男方","女方"]
        
        for g in allcategory{
            let action = UIAction(title:g, handler: {action in
                
                self.guestCheckIn.category = g
            })
            actions.append(action)
        }
        
        categoryButton.menu = UIMenu(children:actions)

    }
    //類別按鈕
    func kindBtn(){
        kindButton.showsMenuAsPrimaryAction = true
        kindButton.changesSelectionAsPrimaryAction = true
        
        var actions: [UIAction] = []
        let allKinds = self.model.getGuestKind()
        
        for k in allKinds{
            let action = UIAction(title:k, handler: {action in
                
                self.guestCheckIn.kind = k
            })
            actions.append(action)
        }
        
        kindButton.menu = UIMenu(children:actions)

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
        
        //檢核姓名
        let name = nameText.text?.trimmingCharacters(in: .whitespaces)
        if (name == ""){
            msg = "請輸入姓名欄位！"
        }else{
            
            //檢查姓名是否重複
            let checkInfo = self.guestInfo.filter{$0.name == name}
            if checkInfo.isEmpty{
                self.guestCheckIn.name = name!
            }else{
                if (checkInfo[0].name == name){
                    msg = "此貴賓已報到，請至賓客名單頁面查詢。"
                }
            }
            
        }
        
        //檢核禮金
        let gift = giftText.text?.trimmingCharacters(in: .whitespaces)
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
        
        //檢核出席
        if (attendButton.isSelected == true){
            self.guestCheckIn.attend = "是"
        }else{
            self.guestCheckIn.attend = "否"
        }
        
        //檢核桌次
        if (desktText.text == ""){
            self.guestCheckIn.desk = ""
        }else{
            self.guestCheckIn.desk = self.desktText.text!
        }
        
        //檢核人數
        let peo = peopleText.text?.trimmingCharacters(in: .whitespaces)
        if (peo == ""){
            //msg = "請輸入人數欄位！"
            self.guestCheckIn.people = "0"
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
   
    
    @IBAction func qrcodeBtn(_ sender: Any) {
    
        let v = self.navigationController?.storyboard?.instantiateViewController(withIdentifier: "QRCode") as? QRCodeViewController
        self.navigationController?.pushViewController(v!, animated: true)
        
    }
    
    @IBAction func sendBtn(_ sender: Any) {

        let indicatorView = self.activityIndicator(style: .medium, center: self.view.center)
        self.view.addSubview(indicatorView)
        indicatorView.startAnimating()

        let check = checkInfo()
        if (check == ""){

            DispatchQueue.main.async(execute: { [self] in

                let insertMsg = self.model.insertGuestInfo(guestCheckIn)

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
