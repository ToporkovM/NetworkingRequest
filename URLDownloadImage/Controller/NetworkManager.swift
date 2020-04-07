//
//  NetworkManager.swift
//  URLDownloadImage
//
//  Created by max on 09.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import Foundation
import UIKit
class NetworkManager {
    //метод загрузки изображения
    static func downloadImage(url: String,completion: @escaping (_ image: UIImage)->()) {
        guard let url = URL(string: url) else { return }
        let session = URLSession.shared
        //метод получающий содержимое по указанному url, а затем обрабатывающий полученную информацию
        session.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                // асинхронно  в главном потоке ловим image в замыкание
                DispatchQueue.main.async {
                    completion(image)
                }
            }
        }.resume()
    }
    //метод наполнения таблицы
    static func fetchData(url: String, completion: @escaping (_ courses: [Course]) -> ()) {
        guard let url = URL(string: url) else { return }
              URLSession.shared.dataTask(with: url)  { (data, _, error) in
                  guard let data = data else { return }
                  do {
                      let decoder = JSONDecoder()
                      decoder.keyDecodingStrategy = .convertFromSnakeCase
                      let courses = try decoder.decode([Course].self, from: data)
                    completion(courses)
                  } catch let error {
                      print(error)
                  }
              }.resume()
    }
    //метод загрузки изображения на сервер
    static func uploadImage(url: String, completion: @escaping (_ textLink: Any)->()) {
        let image = UIImage(named: "торнадо")!
        guard let url = URL(string: url) else { return }
        let httpHeaders = ["Authorization": "Client-ID c0332e5721870e4"]
        guard let imageProperties = imageProperties(withImage: image, forKey: "image") else { return}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = httpHeaders
        request.httpBody = imageProperties.data
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    DispatchQueue.main.async {
                        completion(json)
                    }
                }
                catch {
                    print(error)
                }
                
            }
        }.resume()
    }
}
