//
//  CurrentUsers.swift
//  URLDownloadImage
//
//  Created by max on 27.04.2020.
//  Copyright © 2020 max. All rights reserved.
//

import Foundation

struct CurrentUsers {
    let name: String
    let id: String
//    let email: String
    
    init?(id: String, data: [String: Any]) {
        
        guard let name = data["name"] as? String else { return nil }
//        guard let email = data["email"] as? String else { return nil }
        self.id = id
        self.name = name
//        self.email = email
        
    }
}
