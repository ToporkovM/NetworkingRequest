//
//  MainViewController.swift
//  URLDownloadImage
//
//  Created by max on 09.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit
import UserNotifications
import FBSDKCoreKit
import FirebaseAuth

enum Actions: String, CaseIterable {
    case post = "POST"
    case get = "GET"
    case downloadImage = "Download image"
    case ourCourses = "Our Courses"
    case uploadImage = "Upload image"
    case downloadFiles = "Download files"
    case ourCorsesAlamofire = "Our Courses (Alamofire)"
    case requestData = "requestData"
    case downloadLargeImage = "Download Large Image"
    case postAlamofire = "POST Alamofire"
    case putAlamofire = "PUT Alamofire"
    case uploadImageWithAlamofire = "Upload Alamofire"
}

private let reuseIdentifier = "Cell"
private let swiftBookApi = "https://swiftbook.ru/wp-content/uploads/api/api_courses"

class MainViewController: UICollectionViewController {
    
    private let dataProvider = DataProvider()
    let labelArray = Actions.allCases
    private var alert: UIAlertController!
    private var filePath: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerUserForNotification()
        /*передаем в переменную filePath местоположения файла захваченного из fileLocation(location), убираем алерт, отправляем уведомление
        */
        dataProvider.fileLocation = { (location) in
            self.filePath = location.absoluteString
            self.alert.dismiss(animated: true, completion: nil)
            self.postNotifications()
        }
        
        chekLoggIn()
    }
    
    private func showAlert() {
        alert = UIAlertController(title: "Downloading...", message: "0%", preferredStyle: .alert)
        let height = NSLayoutConstraint(item: self.alert.view!,
                                       attribute: .height,
                                       relatedBy: .equal,
                                       toItem: nil,
                                       attribute: .notAnAttribute,
                                       multiplier: 0,
                                       constant: 170)
        alert.view.addConstraint(height)
        let alertAction = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            self.dataProvider.stopDownload()
        }
        alert.addAction(alertAction)
        present(alert, animated: true) {
            let size = CGSize(width: 40, height: 40)
            let point = CGPoint(x: self.alert.view.frame.width / 2 - size.width / 2,
                                y: self.alert.view.frame.height / 2 - size.height/2)
            let activityIndicator = UIActivityIndicatorView(frame: CGRect(origin: point, size: size))
            activityIndicator.color = .gray
            activityIndicator.startAnimating()
            
            let progresView = UIProgressView(frame: CGRect(x: 0, y: self.alert.view.frame.height - 44, width: self.alert.view.frame.width, height: 2))
            progresView.tintColor = .blue
            self.dataProvider.onProgress = { (progress) in
                progresView.progress = Float(progress)
                self.alert.message = String(Int(progress * 100)) + "%"
                
            }
            self.alert.view.addSubview(activityIndicator)
            self.alert.view.addSubview(progresView)
            
        }
    }
    //MARK: Navigation
    
    // метод который по идентификатору сигвэя запускает определенные методы в выбранных вьюконтроллерах
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //приводим константы к типам вьюконтроллеров
        let coursesVC = segue.destination as? CourseViewController
        let imageVC = segue.destination as? SecondViewController
        let uploadVC = segue.destination as? UploadViewController
        
        switch segue.identifier {
            
        case "OurCourses":
            coursesVC?.fetchData()
        case "OurCoursesAlamofire":
            coursesVC?.fetchDataWithAlamofire()
        case "PostCourse":
            coursesVC?.fetchDataWithPostAlamofire()
        case "PutCourses":
            coursesVC?.putRequest()
        case "imageAlamofire":
            imageVC?.fetchImageDataAlamofire()
        case "DownloadImage":
            imageVC?.urlReguest()
        case "DownloadImageAlamofire":
            imageVC?.downloadImageWithProgress()
        case "UploadImage":
            uploadVC?.uploadImage()
        case "UploadImageWithAlamofire":
            uploadVC?.uploadWithAlamofire()
        default:
            break
        }
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labelArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
        cell.label.text = labelArray[indexPath.row].rawValue
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = labelArray[indexPath.row]
        switch action {
        case Actions.get:
            performSegue(withIdentifier: "GET", sender: self)
        case Actions.post:
            performSegue(withIdentifier: "POST", sender: self)
        case Actions.downloadImage:
            performSegue(withIdentifier: "DownloadImage", sender: self)
        case Actions.ourCourses:
            performSegue(withIdentifier: "OurCourses", sender: self)
        case Actions.uploadImage:
            performSegue(withIdentifier: "UploadImage", sender: self)
        case .downloadFiles:
            dataProvider.startDownload()
            showAlert()
        case Actions.ourCorsesAlamofire:
            performSegue(withIdentifier: "OurCoursesAlamofire", sender: self)
        case Actions.requestData:
            performSegue(withIdentifier: "imageAlamofire", sender: self)
//            AlamofireNetworkRequest.requestCourseData(url: swiftBookApi)
//            AlamofireNetworkRequest.requestCourseString(url: swiftBookApi)
            AlamofireNetworkRequest.request(url: swiftBookApi)
        case Actions.downloadLargeImage:
            performSegue(withIdentifier: "DownloadImageAlamofire", sender: self)
        case Actions.postAlamofire:
            performSegue(withIdentifier: "PostCourse", sender: self)
        case Actions.putAlamofire:
            performSegue(withIdentifier: "PutCourses", sender: self)
        case Actions.uploadImageWithAlamofire:
            performSegue(withIdentifier: "UploadImageWithAlamofire", sender: self)
        }
    }
    
}

extension MainViewController {
    //запрос доступа к уведомлениям
    private func registerUserForNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (_, _) in
            
        }
    }
    //отправка уведомления
    private func postNotifications() {
        let content = UNMutableNotificationContent()
        content.title = "Загрузка завершена!"
        content.body = "Перейти к файлу: \(filePath!)"
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "TransferComplete", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

//MARK: Facebook SDK
    
    extension MainViewController {
        
        //если пользователь не авторизирован, то вернуть LoginViewController
        private func chekLoggIn() {
            
            if Auth.auth().currentUser == nil {
                
                DispatchQueue.main.async {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let loginViewController = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                    loginViewController.modalPresentationStyle = .fullScreen
                    self.present(loginViewController, animated: true)
                    return
                }
            }
        }
    }

