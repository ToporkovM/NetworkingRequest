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
    private let imageUrl = "https://i.imgur.com/3416rvI.jpg"

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var completedLabel: UILabel!

    @IBOutlet weak var compledetProgress: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.hidesWhenStopped = true
        activity.startAnimating()
        compledetProgress.isHidden = true
        completedLabel.isHidden = true
    }
    
    func urlReguest() {
      
        NetworkManager.downloadImage(url: url) { (image) in
            self.activity.stopAnimating()
            self.imageView.image = image
            print("urlRequest")
        }
    }
    
    //метод загрузки изображения с помощью alamofire
    func fetchImageDataAlamofire() {
        
        AlamofireNetworkRequest.downloadImage(url: url) { (image) in
            self.activity.stopAnimating()
            self.imageView.image = image
        }
    }
    
    //
    func downloadImageWithProgress()  {
        
        AlamofireNetworkRequest.onProgress = { (progress) in
            
            self.compledetProgress.isHidden = false
            self.compledetProgress.progress = Float(progress)
        }
        
        AlamofireNetworkRequest.completed = { (completed) in
            
            print("label")
            self.completedLabel.isHidden = false
            self.completedLabel.text = String(completed)
        }
        
        AlamofireNetworkRequest.downloadImageWithProgress(url: imageUrl) { (image) in
            
            print("downloadImageWithProgress")
            self.completedLabel.isHidden = true
            self.compledetProgress.isHidden = true
            self.activity.stopAnimating()
            self.imageView.image = image
        }
    }
}
