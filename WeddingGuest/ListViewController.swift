//
//  ListViewController.swift
//  WeddingGuest
//
//  Created by JuliaWang on 2023/7/1.
//

import UIKit

class ListViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchSegmented: UISegmentedControl!
    
    @IBOutlet weak var searchSV: UIStackView!
    @IBOutlet weak var kindButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchTextField: UITextField!
    
    @IBOutlet weak var tv: UITableView!
    
    //Move Up Down
    var keyInTextField: UITextField!
    //暫存 View 的範圍
    var rect: CGRect?
    
    var model = wViewModel()
    var guestInfo = [guestInformation]()
    var indicatorView:UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //按鈕圓角設定
        kindButton.layer.cornerRadius = 10.0
        kindButton.layer.masksToBounds = true
        searchButton.layer.cornerRadius = 10.0
        searchButton.layer.masksToBounds = true
        
        kindButton.isHidden = true
        searchSV.isHidden = true
        
        searchTextField.delegate = self
        searchTextField.returnKeyType = .done
        
        tv.delegate = self
        tv.dataSource = self
        
        //鍵盤事件
        keyboardNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchSegmented.selectedSegmentIndex = 0
        self.reset()
        self.getInfo()

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.reset()
    }
    
    /*------------------------------畫面處理及初始化------------------------------*/
    
    //reset
    func reset(){
        self.guestInfo.removeAll()
        self.tv.reloadData()
        self.searchTextField.text = ""
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
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.guestInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell", for: indexPath) as? SearchResultTableViewCell
        else{
            return UITableViewCell()
        }
        
        let info = self.guestInfo[indexPath.row]
        cell.nameLabel.text = info.name
        cell.deskLabel.text = info.desk
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? EditViewController,
           let row = tv.indexPathForSelectedRow?.row{
            let guestData = self.guestInfo[row]
            controller.guestCheckIn.name = guestData.name
            controller.guestCheckIn.category = guestData.category
            controller.guestCheckIn.kind = guestData.kind
            controller.guestCheckIn.brideCake = guestData.brideCake
            controller.guestCheckIn.attend = guestData.attend
            controller.guestCheckIn.gift = guestData.gift
            controller.guestCheckIn.desk = guestData.desk
            controller.guestCheckIn.people = String(guestData.nbOfPeople)
        }
    }
   
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            
            let info = self.guestInfo[indexPath.row]
            let msg = self.model.deleteGuestInfo(guestInfo: info)
            self.guestInfo.remove(at: indexPath.row)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){

                let alert = UIAlertController(title: "賓客資料", message: msg , preferredStyle: .alert)

                let confirm = UIAlertAction(title: "確認", style: .default, handler: { action in
                    self.tv.reloadData()
                })

                alert.addAction(confirm)

                //Set-alertController
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func kindBtn(){
        kindButton.showsMenuAsPrimaryAction = true
        kindButton.changesSelectionAsPrimaryAction = true
        
        var actions: [UIAction] = []
        let allKinds = self.model.getGuestKind()
        
        for k in allKinds{
            let action = UIAction(title:k, handler: {action in
                
                self.getsearchInfo("kind", k)
                
            })
            actions.append(action)
        }
        
        kindButton.menu = UIMenu(children:actions)

    }
   
    @IBAction func searchSegControl(_ sender: UISegmentedControl) {
        
        if (sender.selectedSegmentIndex == 0){
            //總覽
            kindButton.isHidden = true
            searchSV.isHidden = true
            reset()
            getInfo()
            
        }else{
            //查詢
            kindButton.isHidden = false
            searchSV.isHidden = false
            reset()
            kindBtn()
        }
    }
    
    
    /*------------------------------資料處理------------------------------*/
  
    //取得資料
    func getInfo(){
        
        self.indicatorView = self.activityIndicator(style: .medium, center: self.view.center)
        self.view.addSubview(indicatorView)
        indicatorView.startAnimating()
        
        self.model.getGuestInfo { [weak self] guestInfo in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self?.guestInfo = guestInfo
                self!.dismiss(animated: true, completion: nil)
                self?.indicatorView.stopAnimating()
                self?.tv.reloadData()
            }
        }
    }
    
    //取得搜尋資料
    func getsearchInfo(_ searchKind:String, _ searchKey:String){
        
        self.indicatorView = self.activityIndicator(style: .medium, center: self.view.center)
        self.view.addSubview(indicatorView)
        indicatorView.startAnimating()
        
        self.model.searchGuestInfo(searchKind, searchKey) { guestInfo in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                self.guestInfo = guestInfo
                self.dismiss(animated: true, completion: nil)
                self.indicatorView.stopAnimating()
                self.tv.reloadData()
            }
        }

    }
    
    @IBAction func searchBtn(_ sender: Any) {
        
        let searchName = self.searchTextField.text?.trimmingCharacters(in: .whitespaces)
        self.getsearchInfo("name", searchName!)
        
    }
    
}
