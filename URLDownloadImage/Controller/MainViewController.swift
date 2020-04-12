//
//  MainViewController.swift
//  URLDownloadImage
//
//  Created by max on 09.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit
import UserNotifications

enum Actions: String, CaseIterable {
    case post = "POST"
    case get = "GET"
    case downloadImage = "Download image"
    case ourCourses = "Our Courses"
    case uploadImage = "Upload image"
    case downloadFiles = "Download files"
    case ourCorsesAlamofire = "Our Courses (Alamofire)"
    case requestData = "requestData"
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
        print("viewDidload")
        registerUserForNotification()
        /*передаем в переменную filePath местоположения файла захваченного из fileLocation(location), убираем алерт, отправляем уведомление
        */
        dataProvider.fileLocation = { (location) in
            self.filePath = location.absoluteString
            self.alert.dismiss(animated: true, completion: nil)
            print("прочеканно")
            self.postNotifications()
            
        }
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let coursesVC = segue.destination as? CourseViewController
        let imageVC = segue.destination as? SecondViewController
        
        switch segue.identifier {
            
        case "OurCourses":
            coursesVC?.fetchData()
            
        case "OurCoursesAlamofire":
            coursesVC?.fetchDataWithAlamofire()
            
        case "imageAlamofire":
            imageVC?.fetchImageDataAlamofire()
            
        case "DownloadImage":
            imageVC?.urlReguest()
        
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
