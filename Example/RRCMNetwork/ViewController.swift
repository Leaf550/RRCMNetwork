//
//  ViewController.swift
//  RRCMNetwork
//
//  Created by fyhNB on 05/01/2021.
//  Copyright (c) 2021 fyhNB. All rights reserved.
//

import UIKit
import RRCMNetwork
import RxSwift

struct Student: Codable {
    let name: String
    let age: Int
    let school: String
    
    static let request = RRCMNetworkRequest(path: "/mock/dcfc39aa3ea22338c24e2696da6aa9ad/AlamofireTest/student", method: .get, parameters: nil, headers: nil)
}

class ViewController: UIViewController {
//    https://www.fastmock.site/mock/dcfc39aa3ea22338c24e2696da6aa9ad/AlamofireTest/student
    
    let network = RRCMNetwork(baseurl: "https://www.fastmock.site")
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        network
            .requestData(Student.request, type: Student.self)
            .subscribe { (stu) in
                print(stu.name)
                print(stu.age)
                print(stu.school)
        } onError: { (err) in
            print(err)
        } onCompleted: {
            print("completed")
        } onDisposed: {
            print("disposed")
        }.disposed(by: disposeBag)

    }

}

