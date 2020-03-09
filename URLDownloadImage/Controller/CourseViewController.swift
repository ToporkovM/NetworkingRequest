//
//  CourseViewController.swift
//  URLDownloadImage
//
//  Created by max on 03.03.2020.
//  Copyright © 2020 max. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController {
    private var courses = [Course]()
    private var coursName: String?
    private var courseUrl: String?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    func fetchData() {
        let jsonUrlString = "https://swiftbook.ru/wp-content/uploads/api/api_courses"
        guard let url = URL(string: jsonUrlString) else { return }
        URLSession.shared.dataTask(with: url)  { (data, response, error) in
            guard let data = data else { return }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                self.courses = try decoder.decode([Course].self, from: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error)
            }
            
        }.resume()
    }
    
   private func cofigureCell(cell: CourseTableViewCell, for indexPath: IndexPath) {
        let course = courses[indexPath.row]
        cell.courseNameLabel.text = course.name
        if let nomberOfLesson = course.numberOfLessons {
            cell.nomberOfLesson.text = "Заданий - \(nomberOfLesson)"
        }
        if let nomberOfTest = course.numberOfTests {
            cell.nomberOfTest.text = "Тестов -  \(nomberOfTest)"
        }
        DispatchQueue.global().async {
            guard let imageUrl = URL(string: course.imageUrl!) else { return }
            guard let imageData = try? Data(contentsOf: imageUrl) else { return }
            DispatchQueue.main.async {
                cell.cellImageView.image = UIImage(data: imageData)
            }
    }
    
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let webViewController = segue.destination as! WebViewController
        webViewController.selectedCourse = coursName
//        if let url = courseUrl {
            webViewController.courseURL = courseUrl!
//        }
    }

}

//MARK: TableViewDataSource
extension CourseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CourseTableViewCell
        cofigureCell(cell: cell, for: indexPath)
        return cell
    }
}

//MARK: TableViewDelegate
extension CourseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let course = courses[indexPath.row]
        coursName = course.name
        courseUrl = course.link
        performSegue(withIdentifier: "web", sender: self)
    }
    
}

