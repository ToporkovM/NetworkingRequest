//
//  POSTViewController.swift
//  URLDownloadImage
//
//  Created by max on 03.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit

class POSTViewController: UIViewController {

    @IBOutlet weak var POSTActivity: UIActivityIndicatorView!
    @IBOutlet weak var POSTTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        POSTActivity.isHidden = true
        POSTActivity.hidesWhenStopped = true

        postReques()
    }
    

    func postReques() {
        POSTActivity.isHidden = false
        POSTActivity.startAnimating()
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1/comments") else { return }
        //константа в виде словаря ключ-значения
        let userData = ["name": "Maxim", "profession": "developer"]
        //запрос по заданному url адресу
        var request = URLRequest(url: url)
        //метод запроса - POST
        request.httpMethod = "POST"
        //создаем тело запроса, которое является приведенным в формат json словаря userData
        guard let httpBody = try? JSONSerialization.data(withJSONObject: userData, options: []) else { return }
        //присваеваем телу запроса созданную константу httpBody
        request.httpBody = httpBody
        //добавляем в поле заголовка отправленные данные
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard let data = data, let response = response else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                DispatchQueue.main.async {
                    self.POSTTextView.text = "Ответ сервера - \(response), загруженные данные в формате JSON - \(json)"
                    self.POSTActivity.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async{
                self.POSTTextView.text = "Error - \(error)"
                    self.POSTActivity.stopAnimating()
                }
            }
        }.resume()
        
    }

}
