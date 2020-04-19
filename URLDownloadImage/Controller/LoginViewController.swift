//
//  LoginViewController.swift
//  URLDownloadImage
//
//  Created by max on 19.04.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    lazy var fbLoginButton = { () -> FBLoginButton in
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32, y: 320, width: self.view.frame.width - 64, height: 50)
        loginButton.delegate = self
        return loginButton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
        updateView()
        if AccessToken.isCurrentAccessTokenActive {
            print("logget in")
        }
    }
    
    private func updateView() {
        view.addSubview(fbLoginButton)
    }
    
    private func setGradientBackground() {
        let colorTop =  UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 255.0/255.0, green: 94.0/255.0, blue: 58.0/255.0, alpha: 1.0).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds

        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            guard let errorNotOptional = error else { return }
            print(errorNotOptional)
        }
        print("successfully logget in")
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("Did log out")

    }
    
    
}
