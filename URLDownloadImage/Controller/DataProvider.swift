//
//  DataProvider.swift
//  URLDownloadImage
//
//  Created by max on 03.04.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit

class DataProvider: NSObject {
    
    private var downloadTask: URLSessionDownloadTask!
    
    var onProgress: ((Double) -> ())?
    
    var fileLocation: ((URL) -> ())?
    
    private lazy var bgSession: URLSession = {
        /* определяет поведение сессии призагрузке и выгрузке данных
         для возможности загрузки в бэкграунде, вызываем метод backround
         и присваеваем идентификатор приложения
        */
        var config = URLSessionConfiguration.background(withIdentifier: "Max-T.URLDownloadImage")
//        config.isDiscretionary = true
        // после завершения загрузки данных приложение запустится в фоновом режиме
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
    }()
    
    func startDownload() {
        if let url = URL(string: "https://speed.hetzner.de/100MB.bin") {
            downloadTask = bgSession.downloadTask(with: url)
            //время до начала загрузки, сек.
            downloadTask.earliestBeginDate = Date().addingTimeInterval(3)
            //кол-во байтов которые клиент планирует отправить
            downloadTask.countOfBytesClientExpectsToSend = 512
            //кол-во байтов которые клиент планирует получить
            downloadTask.countOfBytesClientExpectsToReceive = 100 * 1024 * 1024
            downloadTask.resume()
        }
    }
    
    func stopDownload() {
        downloadTask.cancel()
    }

}

extension DataProvider: URLSessionDelegate {
    /* метод вызывается после завершения всех задач помещенных в очередь с идентификатором этого приложения
    */
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard
                //экземпляр класса UIApplication приведенный к типу SceneDelegate,
                let sceneDelegate = UIApplication.shared.delegate as? SceneDelegate,
                //передаем захваченное значение сессии из свойства bgSessionCompletionHandler
                let completionHandler = sceneDelegate.bgSessionCompletionHandler
                else { return }
            //обнуляем значение замыкания
            sceneDelegate.bgSessionCompletionHandler = nil
            //вызываем исходное св-во, для того чтобы уведомить систему о завершении загрузки
            completionHandler()
        }
    }
}

extension DataProvider: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("didFinish - \(location.absoluteString)")
        DispatchQueue.main.async {
            self.fileLocation?(location)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite != NSURLSessionTransferSizeUnknown else { return }
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        print(progress)
        DispatchQueue.main.async {
            self.onProgress?(progress)
        }
    }
    
}
