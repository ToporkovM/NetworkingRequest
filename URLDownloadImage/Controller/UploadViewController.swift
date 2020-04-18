//
//  UploadViewController.swift
//  URLDownloadImage
//
//  Created by max on 09.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit

class UploadViewController: UIViewController {
    private let url = "https://api.imgur.com/3/image"
    @IBOutlet weak var uploadTextView: UITextView!
    @IBOutlet weak var uploadActivity: UIActivityIndicatorView!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        uploadActivity.isHidden = true
        uploadActivity.hidesWhenStopped = true
        uploadActivity.startAnimating()
    }
    
    func uploadImage() {
        
        NetworkManager.uploadImage(url: url) { (json) in
            DispatchQueue.main.async {
                self.uploadTextView.text = "Cсылка - \(json)"
                self.uploadActivity.stopAnimating()
            }
        }
    }
    
    func uploadWithAlamofire() {
        
        AlamofireNetworkRequest.uploadImageWithAlamofire(url: url) { (json) in
            DispatchQueue.main.async {
                self.uploadActivity.stopAnimating()
                self.uploadTextView.text = "Ссылка в link - \(json)"
            }
        }
    }
}
