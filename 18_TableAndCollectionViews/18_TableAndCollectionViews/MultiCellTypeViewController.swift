//
//  MultiCellTypeViewController.swift
//  18_TableAndCollectionViews
//
//  Created by Sang Tae Kim on 2017. 7. 23..
//  Copyright © 2017년 haibane. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources
import RxCocoa

enum MyData {
    case banner(String)
    case deal(String, String)
}
class MultiCellTypeViewController: UIViewController {
    let tableView = UITableView()
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", options: [], metrics: [:], views: ["tableView": tableView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: [:], views: ["tableView": tableView]))
        
        bindTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func bindTableView() {
        let section1: Observable<[MyData]> = Observable.of([.banner("배너 1"), .deal("딜 1", "설명 설명"), .deal("딜 2", "설명 설명 설명 설명")])
        
        section1.bind(to: tableView.rx.items) {
            (tableView: UITableView, index: Int, element: MyData) in
            switch element {
            case .banner(let title):
                let cell = UITableViewCell(style: .default, reuseIdentifier:
                    "bannerCell")
                cell.textLabel?.text = title
                return cell
            case .deal(let title, let description):
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier:
                    "titleCell")
                cell.textLabel?.text = title
                cell.detailTextLabel?.text = description
                return cell
            }
        }.addDisposableTo(disposeBag)
        
//        tableView.rx.setDelegate(self)
//        .addDisposableTo(disposeBag)
    }
}

extension MultiCellTypeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // you can also fetch item
        return CGFloat(100)
    }    
}
