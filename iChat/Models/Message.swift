//
//  Message.swift
//  iChat
//
//  Created by Abdalla Elsaman on 4/17/19.
//  Copyright © 2019 Dumbies. All rights reserved.
//

import Foundation
import Firebase

class Message: NSObject {
    var fromId: String?
    var text: String?
    var toId: String?
    var timeStamp: Int?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId: fromId
    }
    
}
