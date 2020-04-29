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
import GoogleSignIn

class UserProfileVC: UIViewController {
    
    private var provider: String?
    private var currentUser: CurrentUsers?
    
    private lazy var signOutButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 32,
        y: self.view.frame.height - 110,
        width: self.view.frame.width - 64,
        height: 50)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 0.5
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(signOut), for: .touchUpInside)
        return button
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
        self.view.addSubview(signOutButton)
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

extension UserProfileVC {
    
    //если sinUp, то открываем loginViewController
    private func openLoginVC() {
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
                    self.currentUser = CurrentUsers(id: uid, data: usersData)
                    self.activityIndicator.stopAnimating()
                    self.userNameLabel.isHidden = false
                    self.userNameLabel.text = self.getProviderData()
                    
                }) { (error) in
                    print(error)
            }
        }
    }
    
    @objc func signOut() {
        
        if let providerData = Auth.auth().currentUser?.providerData {
            
            for userInfo in providerData {
                
                switch userInfo.providerID {
                case "facebook.com":
                    print("Log out of to Facebook")
                    LoginManager().logOut()
                    openLoginVC()
                case "google.com":
                    openLoginVC()
                    GIDSignIn.sharedInstance()?.signOut()
                    print("Log out of to Google")
                default:
                    print("Log out of to \(userInfo.providerID))")
                }
            }
        }
    }
    
    private func getProviderData() -> String {
        
        var byeMessage = ""
        
        if let providerData = Auth.auth().currentUser?.providerData {
            
            for userInfo in providerData {
                
                switch userInfo.providerID {
                case "facebook.com":
                    provider = "Facebook"
                case "google.com":
                    provider = "Google"
                default:
                    break
                }
            }
            byeMessage = "\(currentUser?.name ?? "Noname") \n logget out \n with \(provider ?? "App")"
        }
        return byeMessage
    }
}


