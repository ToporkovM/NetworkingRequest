//
//  SecondViewController.swift
//  URLDownloadImage
//
//  Created by max on 02.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit
import Alamofire
class SecondViewController: UIViewController {
    
    //создаем константу с url адресом картинки
    private let url = "https://applelives.com/wp-content/uploads/2016/05/NYfigU2-681x1079.jpg"

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity.hidesWhenStopped = true
        self.activity.startAnimating()
    }
    
    func urlReguest() {
        
       
        NetworkManager.downloadImage(url: url) { (image) in
            self.activity.stopAnimating()
            self.imageView.image = image
        }
    }
    //метод загрузки изображения с помощью alamofire
    func fetchImageDataAlamofire() {
        
        AF.request(url).responseData { (responseData) in

            switch responseData.result {

            case .success(let data):
                guard let image = UIImage(data: data) else { return }
                self.activity.stopAnimating()
                self.imageView.image = image

            case .failure(let error):
                print(error)
            }
        }
    }
}
