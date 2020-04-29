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
    
    init?(id: String, name: [String: Any]) {
        
        guard let name = name["name"] as? String else { return nil }
        self.id = id
        self.name = name
    }
}
