//
//  SummaryViewController.swift
//  WeddingGuest
//
//  Created by JuliaWang on 2023/7/1.
//

import UIKit

class SummaryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var kindSegmented: UISegmentedControl!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var tv: UITableView!
    
    var model = wViewModel()
    var guestInfo = [guestInformation]()
    var indicatorView:UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        reset()
        tv.dataSource = self
        tv.delegate = self
        tv.allowsSelection = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reset()
        getInfo()
        self.kindSegmented.selectedSegmentIndex = 2
    }
    
    /*------------------------------畫面處理及初始化------------------------------*/
    //reset
    func reset(){
        self.guestInfo.removeAll()
        self.tv.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guestInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "summaryCell", for: indexPath) as? SummaryTableViewCell
                
        else{
            return UITableViewCell()
        }
        
        let info = self.guestInfo[indexPath.row]
        cell.nameLabel.text = info.name
        cell.giftLabel.text = info.gift
        
        return cell
    }
    
    
    @IBAction func kindSeg(_ sender: UISegmentedControl) {
        
        
        if (sender.selectedSegmentIndex == 0){
            //男方
            reset()
            self.getsearchInfo("category", "男方")
            
        }else if (sender.selectedSegmentIndex == 1){
            //女方
            reset()
            self.getsearchInfo("category", "女方")
        }else{
            //男女合計
            reset()
            self.getInfo()
        }
        
    }
    
    /*------------------------------資料處理------------------------------*/
    
    //取得全部資料
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
                self!.summaryResult()
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
                self.summaryResult()
            }
        }
    }
    
    //統計金額
    func summaryResult(){
        
        var amount = 0
        for c in self.guestInfo{
            amount += Int(c.gift)!
        }
        self.amountLabel.text = "禮金總計：\(amount)"
    }

}
