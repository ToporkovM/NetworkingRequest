//
//  UserProfileVC.swift
//  URLDownloadImage
//
//  Created by max on 20.04.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase

class UserProfileVC: UIViewController {
    
    private lazy var fbLoginButton = { () -> FBLoginButton in
        
        let loginButton = FBLoginButton()
        loginButton.frame = CGRect(x: 32,
                                   y: self.view.frame.height - 170,
                                   width: self.view.frame.width - 64,
                                   height: 50)
        loginButton.delegate = self
        return loginButton
    }()
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
        updateView()
        userNameLabel.isHidden = true

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchDataFirebase()
    }
    
    private func updateView() {
        self.view.addSubview(fbLoginButton)
    }
    
    private func setGradientBackground() {
        let colorTop =  UIColor(red: 210.0/255.0, green: 109.0/255.0, blue: 108.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 107/255, green: 148/255, blue: 230/255, alpha: 1).cgColor

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.view.bounds

        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UserProfileVC: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        if error != nil {
            guard let errorNotOptional = error else { return }
            print(errorNotOptional)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true)
                return
            }
        } catch let error {
            print("failed \(error.localizedDescription)")
        }
    }
    
    /* проверяет авторизацию пользователя, если активна, то делает запрос в ветку child("users")
     и child(uid), получает из них данные парсит в модель CurrentUsers и подставляет имя в Label
    */
    private func fetchDataFirebase() {
        
        if Auth.auth().currentUser != nil {
            
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.database().reference()
                .child("users")
                .child(uid)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    guard let usersData = snapshot.value as? [String: Any] else { return }
                    let currentUsers = CurrentUsers(id: uid, name: usersData)
                    self.activityIndicator.stopAnimating()
                    self.userNameLabel.isHidden = false
                    self.userNameLabel.text = "\(currentUsers?.name ?? "Default user") \n log out"
                    
                }) { (error) in
                    print(error)
            }
        }
    }
    
    }


