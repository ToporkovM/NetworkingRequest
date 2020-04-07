//
//  SecondViewController.swift
//  URLDownloadImage
//
//  Created by max on 02.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    //создаем константу с url адресом картинки
    private let url = "https://applelives.com/wp-content/uploads/2016/05/NYfigU2-681x1079.jpg"

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
        NetworkManager.downloadImage(url: url) { (image) in
            self.activity.stopAnimating()
            self.imageView.image = image
        }
    }
    
}
