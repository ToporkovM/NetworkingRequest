//
//  imageUploadManager.swift
//  URLDownloadImage
//
//  Created by max on 09.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import Foundation
import UIKit
struct imageProperties {
    let key: String
    let data: Data
    
    init?(withImage image: UIImage, forKey key: String) {
        self.key = key
        guard let data = image.pngData() else { return nil }
        self.data = data
        
    }
}
