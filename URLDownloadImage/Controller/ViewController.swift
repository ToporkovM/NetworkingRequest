//
//  ViewController.swift
//  URLDownloadImage
//
//  Created by max on 02.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

   
    @IBOutlet weak var downloadLabel: UIButton!
    
    @IBOutlet weak var GETLabel: UIButton!
    @IBOutlet weak var POSTLabel: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        radius()
    }
    
    @IBAction func downloadImage(_ sender: Any) {
    }
    @IBAction func GET(_ sender: Any) {
    }
    @IBAction func POST(_ sender: Any) {
    }
    func radius() {
        downloadLabel.layer.cornerRadius = 16
        GETLabel.layer.cornerRadius = 16
        POSTLabel.layer.cornerRadius = 16
        
    }
    
    }




