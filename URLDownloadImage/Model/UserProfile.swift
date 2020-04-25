//
//  UserProfile.swift
//  URLDownloadImage
//
//  Created by max on 25.04.2020.
//  Copyright © 2020 max. All rights reserved.
//

import Foundation

struct UserProfile {
    
    var id: Int?
    var name: String?
    
    init(data: [String: Any]) {
        
        let id = data["id"] as? Int
        let name = data["name"] as? String
        self.id = id
        self.name = name
    }
}
