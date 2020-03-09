//
//  Course.swift
//  URLDownloadImage
//
//  Created by max on 03.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import Foundation
struct Course: Decodable {
    var id: Int?
    var name: String?
    var link: String?
    var imageUrl: String?
    var numberOfLessons: Int?
    var numberOfTests: Int?
}
