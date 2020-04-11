//
//  AlamofireNetworkRequest.swift
//  URLDownloadImage
//
//  Created by max on 09.04.2020.
//  Copyright © 2020 max. All rights reserved.
//

import Foundation
import Alamofire

class AlamofireNetworkRequest {
    static func sendRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        guard let url = URL(string: url) else { return }
        
        /* Делаем get запрос с помощью alamofire, получаем данные в формате json, ответ(response) приходит в замыкание в виде json
         */
        AF.request(url, method: .get).validate().responseJSON { (response) in
            
            guard let statusCode = response.response?.statusCode else { return }
            print(statusCode)
            
            switch response.result {
            case .success(let value):
                print(value)
                var courses = [Course]()
                courses = Course.getArray(from: value)!
                //захватываем массив courses в замыкании
                completion(courses)
//                print(courses)
                
                
            case .failure(let error):
                print(error)
            }
        }
        
    }
}
