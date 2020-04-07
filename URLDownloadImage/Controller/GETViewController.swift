//
//  GETViewController.swift
//  URLDownloadImage
//
//  Created by max on 02.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit

class GETViewController: UIViewController {
    
    @IBOutlet weak var GETActivity: UIActivityIndicatorView!
    @IBOutlet weak var GETTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GETActivity.isHidden = true
        GETActivity.hidesWhenStopped = true
        GETRequest()

        
    }
    
    func GETRequest() {
        GETActivity.isHidden = false
        GETActivity.startAnimating()
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1/comments") else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            guard let data = data, let response = response else { return }
            do {
                //константа приводящая константу data, полученную с сервера в ходе get запроса к типу json
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                DispatchQueue.main.async {
                    self.GETTextView.text = "Ответ сервера - \(response)  JSON - \(json)"
                    self.GETActivity.stopAnimating()
                }
            } catch {
                DispatchQueue.main.async {
                self.GETTextView.text = "\(error)"
                    self.GETActivity.stopAnimating()
                }
            }
        }.resume()
        
    }

   

}
