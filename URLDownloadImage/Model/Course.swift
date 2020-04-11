//
//  Course.swift
//  URLDownloadImage
//
//  Created by max on 03.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import Foundation

//модель для работы с urlSession
/*
struct Course: Decodable {
    var id: Int?
    var name: String?
    var link: String?
    var imageUrl: String?
    var numberOfLessons: Int?
    var numberOfTests: Int?
}
*/

//модель для работы с alamofire
struct Course: Decodable {
    var id: Int?
    var name: String?
    var link: String?
    var imageUrl: String?
    var numberOfLessons: Int?
    var numberOfTests: Int?
    
    /* опцианальный инициализатор принимающий масив типа [String:Any], внутри которого
     кастим до нужных типов и присваеваем их значения модели
    */
    init?(json: [String:Any]) {
        let id = json["id"] as? Int
        let name = json["name"] as? String
        let link = json["link"] as? String
        let imageUrl = json["imageUrl"] as? String
        let numberOfLessons = json["number_of_lessons"] as? Int
        let numberOfTests = json["number_of_tests"] as? Int
        
        self.id = id
        self.name = name
        self.link = link
        self.imageUrl = imageUrl
        self.numberOfLessons = numberOfLessons
        self.numberOfTests = numberOfTests
    }
    
    static func getArray(from jsonArray: Any) -> [Course]? {
        //если можно привести данные в массив с типом [String: Any]
        guard let jsonArray = jsonArray as? Array<[String: Any]> else { return nil }
        //возвращаем упорядоченный массив приведенных к определенному типу элементов
        return jsonArray.compactMap { Course(json: $0) }
    }
}
