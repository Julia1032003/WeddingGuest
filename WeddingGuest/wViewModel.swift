//
//  wViewModel.swift
//  WeddingGuest
//
//  Created by JuliaWang on 2023/6/26.
//

import Foundation
import UIKit

public class wViewModel{
    
    var msg = ""
    var guestInfo = [guestInformation]()
    var guestCheckIn = guestCheckInData()
    var sheetDBUrl = "https://sheetdb.io/api/v1/1si2oq3vbeqwv"
  
    //賓客種類
    enum guestKind:String{
        case groomRelatives = "新郎親戚",
             groomFriend = "新郎朋友",
             groomColleague = "新郎同事",
             gParentsFriend = "新郎父母朋友",
             brideRelatives = "新娘親戚",
             brideFriend = "新娘朋友",
             brideColleague = "新娘同事",
             bParentsFriend = "新娘父母朋友"
    }

    //喜餅
    enum cakeCheck:String{
        case Y = "已領", N = "未領", C = "小餅乾", Non = "無喜餅"
    }

    //是否出席
    enum YorN:String{
        case Y = "是", N = "否"
    }
    
    //取得賓客種類
    func getGuestKind() -> [String] {
        let allKinds: [guestKind] = [
            .groomRelatives,
            .groomFriend,
            .groomColleague,
            .gParentsFriend,
            .brideRelatives,
            .brideFriend,
            .brideColleague,
            .bParentsFriend
        ]
        
        let stringArray = allKinds.map { $0.rawValue }
        return stringArray
    }
    
    //取得全部資料
    //func getGuestInfo()-> [guestInformation]{
    func getGuestInfo(completion: @escaping ([guestInformation]) -> Void) {
       
        self.guestInfo.removeAll()
        let urlStr = sheetDBUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlStr!)
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if let data = data, let content = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]]{
                
                for guest in content{
                    if let data = guestInformation(json:guest){
                        self.guestInfo.append(data)
                    }
                }
                completion(self.guestInfo)
               
            }
        }
        task.resume()
        
        //return self.guestInfo
    }
    
    //新增資料
    func insertGuestInfo(_ guestComfirm: guestCheckInData)->String{
        
        let url = URL(string: sheetDBUrl)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let guestConfirm:[String:String] = ["name":guestComfirm.name,"category":guestComfirm.category, "kind":guestComfirm.kind, "brideCake":guestComfirm.brideCake, "attend":guestComfirm.attend, "gift":guestComfirm.gift, "desk":guestComfirm.desk, "people":String(guestComfirm.people)]
        
        //Post API 需要在物件（Object）內設定key值為data, value為一個物件的陣列（Array）
        let postData: [String: Any] = ["data" : guestConfirm]
        do{
            //將Data轉為JSON格式
            let data = try JSONSerialization.data(withJSONObject: postData, options: [])
            //背景上傳資料
            let task = URLSession.shared.uploadTask(with: urlRequest, from: data){ (gData, res, err) in
                NotificationCenter.default.post(name: Notification.Name("waitMessage"), object: nil, userInfo: ["message": true])
            }
            task.resume()
            self.msg = "新增成功！"
            
        }catch{
            self.msg = "新增失敗，請重新再試！"
        }
     
        return self.msg
    }
    
    //修改資料
    func modifyGuestInfo(_ guestComfirm: guestCheckInData)->String{
        
        let url = URL(string: "\(sheetDBUrl)/name/\(guestComfirm.name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        var urlRequest = URLRequest(url: url!)
        urlRequest.httpMethod = "PUT"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let guestConfirm:[String:String] = ["name":guestComfirm.name, "kind":guestComfirm.kind, "brideCake":guestComfirm.brideCake, "attend":guestComfirm.attend, "gift":guestComfirm.gift, "desk":guestComfirm.desk, "people":String(guestComfirm.people)]
        
        //PUT API 需要在物件（Object）內設定key值為data, value為一個物件的陣列（Array）
        let postData: [String: Any] = ["data" : guestConfirm]
        do {
            //將Data轉為JSON格式
            let data = try JSONSerialization.data(withJSONObject: postData, options: [])
            //背景上傳資料
            let task = URLSession.shared.uploadTask(with: urlRequest, from: data) { (retData, res, err) in
                NotificationCenter.default.post(name: Notification.Name("waitMessage"), object: nil, userInfo: ["message": true])
            }
            task.resume()
            NotificationCenter.default.post(name: Notification.Name("waitMessage"), object: nil, userInfo: ["message": false])
            self.msg = "修改成功！"
        }
        catch{
            self.msg = "修改失敗，請重新再試！"
        }
        
        return self.msg
    }
    
    //刪除資料
    func deleteGuestInfo(guestInfo:guestInformation)->String{
        
        if let urlStr = "\(sheetDBUrl)/name/\(guestInfo.name)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlStr){
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "DELETE"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let guest = CheckIn(guestData: guestInfo)
            let jsonEncoder = JSONEncoder()
            if let data = try? jsonEncoder.encode(guest){
                let task = URLSession.shared.uploadTask(with: urlRequest, from: data){ [self](gData,response, error)in
                    
                    let decoder = JSONDecoder()
                    if let gData = gData , let dic = try? decoder.decode([String:Int].self, from:gData),dic["deleted"] == 1{
                        self.msg = "刪除成功！"
                    }
                }
                task.resume()
                self.msg = "刪除成功！"
                
            }else{
                self.msg = "刪除失敗，請重新再試！"
            }
        }
        return self.msg
    }
    
    //判斷數字
    func isNumericString(_ input: String) -> Bool {
        let decimalDigits = CharacterSet.decimalDigits
        return input.rangeOfCharacter(from: decimalDigits.inverted) == nil
    }
    

    //尋找
    func searchGuestInfo(_ searchKind: String, _ searchKey: String, completion: @escaping ([guestInformation]) -> Void) {

        self.guestInfo.removeAll()
        let urlStr = "\(sheetDBUrl)/search?\(searchKind)=\(searchKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url = URL(string: urlStr!)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let data = data, let content = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]] {

                for guest in content {
                    if let data = guestInformation(json: guest) {
                        self.guestInfo.append(data)
                    }
                }
                
                completion(self.guestInfo)
            }
        }
        task.resume()
    }

//    func searchGuestInfo(_ searchKind:String, _ searchKey:String)-> [guestInformation]{
//
//        let url = URL(string: "\(sheetDBUrl)/Search?\(searchKind)=\(searchKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
//        let task = URLSession.shared.dataTask(with: url!){ (data, response, error) in
//            if let data = data, let content = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [[String: Any]]{
//
//                for guest in content{
//                    if let data = guestInformation(json: guest){
//                        self.guestInfo.append(data)
//                    }
//                }
//            }
//        }
//        task.resume()
//
//        return self.guestInfo
//    }
    
    
}
