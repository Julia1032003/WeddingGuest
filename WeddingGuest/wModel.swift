//
//  wModel.swift
//  WeddingGuest
//
//  Created by JuliaWang on 2023/6/26.
//

import Foundation

//顯示資料、上傳及下載sheetDB及下載資料用的
struct guestInformation : Codable{
    var name: String
    var category: String
    var kind: String
    var brideCake: String
    var attend: String
    var gift: String
    var desk: String
    var nbOfPeople:Int
        
        
    init?(json: [String : Any]) {
        guard let Name = json["name"] as? String,
              let Category = json["category"] as? String,
              let Kind = json["kind"] as? String,
              let BrideCake = json["brideCake"] as? String,
              let Attend = json["attend"] as? String,
              let Gift = json["gift"] as? String,
              let Desk = json["desk"] as? String,
              let people = json["people"] as? String
                
            else {
                return nil
            }
            self.name = Name
            self.category = Category
            self.kind = Kind
            self.brideCake = BrideCake
            self.attend = Attend
            self.gift = Gift
            self.desk = Desk
            self.nbOfPeople = Int(people)!
    }
}

//刪除及修改sheetDB資料用的
struct CheckIn:Encodable {
    var guestData:guestInformation
}

//賓客報到
struct guestCheckInData{
    var name: String
    var category:String
    var kind: String
    var brideCake: String
    var attend: String
    var gift: String
    var desk: String
    var people:String
    
    init(){
        
        name = ""
        category = ""
        kind = ""
        brideCake = ""
        attend = ""
        gift = ""
        desk = ""
        people = ""
        
    }
}

//賓客種類
//enum guestKind:String{
//    case groomRelatives = "新郎親戚",
//         groomFriend = "新郎朋友",
//         groomColleague = "新郎同事",
//         gParentsFriend = "新郎父母朋友",
//         brideRelatives = "新娘親戚",
//         brideFriend = "新娘朋友",
//         brideColleague = "新娘同事",
//         bParentsFriend = "新娘父母朋友"
//}

////喜餅
//enum cakeCheck:String{
//    case Y = "已領", N = "未領", C = "小餅乾", Non = "無喜餅"
//}
//
////是否出席
//enum YorN:String{
//    case Y = "是", N = "否"
//}

//Note
//App背景色碼-R:G:B:
//Button色碼-R:G:B:
//QRCode色碼-R:G:B:


