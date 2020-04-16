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
    
    static var onProgress: ((Double) -> ())?
    static var completed: ((String) -> ())?
    
    // получение данных в формате json
    static func sendRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        guard let url = URL(string: url) else { return }
        
        /* Делаем get запрос с помощью alamofire, получаем данные в формате json, ответ(response) приходит в замыкание в виде json */
        AF.request(url, method: .get).validate().responseJSON { (response) in
            
            guard let statusCode = response.response?.statusCode else { return }
            print(statusCode)
            
            switch response.result {
            case .success(let value):
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
    //получение данных в формате data с помощью alamofire
    static func requestCourseData(url: String) {
        AF.request(url).responseData { (responseData) in
            
            switch responseData.result {
            case .success(let data):
                guard let string = String(data: data, encoding: .utf8) else { return }
                print(string)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //получение данных в формате  string  c помощью alamofire
    static func requestCourseString(url: String) {
        AF.request(url).responseString { (responseString) in
            
            switch responseString.result {
            case .success(let string):
                print(string)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /* метод не обрабатывает данные, а оставляет их в том виде, в котором
     они пришли с сервера, для последующей обработки в ручную */
    static func request(url: String) {
        AF.request(url).response { (response) in
            guard
                let data = response.data,
                let string = String(data: data, encoding: .utf8)
                else { return }
            print(string)
        }
    }
    
    //загрузка изображения
    static func downloadImage(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        
        AF.request(url).responseData { (responseData) in
            
            switch responseData.result {
            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                completion(image)
            case .failure(let error):
                print(error)
            }
        }
    }
    //загрузка изображения с указанием прогресса
    static func downloadImageWithProgress(url: String, completion: @escaping (_ image: UIImage) -> ()) {
        guard let url = URL(string: url) else { return }
        
        AF.request(url).downloadProgress { (progress) in
             print("\(progress.localizedDescription!)")
            self.onProgress?(progress.fractionCompleted)
            self.completed?(progress.localizedDescription)
        }.response { (responseData) in
            guard let data = responseData.data, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    //post запрос
    static func postWithAlamofire(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        
        guard let url = URL(string: url) else { return }
        let userData: [String: Any] = [
            "name": "Network Requests",
            "link": "https://swiftbook.ru/contents/our-first-applications/",
            "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png"
        ]
        AF.request(url, method: .post, parameters: userData, encoding: JSONEncoding.default).validate().responseJSON { (responseJSON) in
            
            guard let statusCode = responseJSON.response?.statusCode else { return }
            print(statusCode)
            
            switch responseJSON.result {
                
            case .success(let value):
                guard
                    let jsonObject = value as? [String:Any],
                    let course = Course(json: jsonObject)
                    else { return }
                print(jsonObject)
                var courses = [Course]()
                courses.append(course)
                print(courses)
                completion(courses)
   
            case .failure(let error):
                print(error)
            }
        }
    }
    // put запрос
    static func putRequest(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        
        let putUserData: [String:Any] = [
            "name": "Network PUT Requests",
            "link": "https://swiftbook.ru/contents/our-first-applications/",
            "imageUrl": "https://swiftbook.ru/wp-content/uploads/sites/2/2018/08/notifications-course-with-background.png"
        ]
        AF.request(url, method: .put, parameters: putUserData).validate().responseJSON { (responseJSON) in
            
            guard let statusCode = responseJSON.response?.statusCode else { return }
            print(statusCode)
            
            switch responseJSON.result {
                
            case .success(let value):
                guard
                    let jsonObject = value as? [String:Any],
                    let course = Course(json: jsonObject)
                    else { return }
                var courses = [Course]()
                courses.append(course)
                completion(courses)
            case .failure(let error):
                print(error)
            }
        }
    }
}
