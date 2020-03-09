//
//  SecondViewController.swift
//  URLDownloadImage
//
//  Created by max on 02.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        urlReguest()
        activity.isHidden = true
        activity.hidesWhenStopped = true
        
    }
    
    func urlReguest() {
        //начало анимации
        self.activity.startAnimating()
        //видимость активити индикатора
        self.activity.isHidden = false
        //создаем константу с url адресом картинки
        guard let url = URL(string: "https://applelives.com/wp-content/uploads/2016/05/NYfigU2-681x1079.jpg") else { return }
        //константа синглтона класса URLSession
        let session = URLSession.shared
        //метод получающий содержимое по указанному url, а затем обрабатывающий полученную информацию
        session.dataTask(with: url) { (data, response, error) in
            if let data = data, let image = UIImage(data: data) {
                //в асинхронном главном потоке останавлевает активити индикатор и присваевает картику imageView, чтобы не препядствовать загрузки в главном потоке
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.imageView.image = image
                }
            }
        }.resume()
    }
    
}
