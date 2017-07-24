//
//  ViewController.swift
//  18_TableAndCollectionViews
//
//  Created by Sang Tae Kim on 2017. 7. 23..
//  Copyright © 2017년 haibane. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Basic"
        bindTableView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    fileprivate func bindTableView() {
        let menu = Observable.of(["multi1", "multi2", "multi3"])
        
        menu.bind(to: tableView.rx.items) {
            (tableView: UITableView, index: Int, element: String) in
            let cell = UITableViewCell(style: .default, reuseIdentifier:
                "cell")
            cell.textLabel?.text = element
            cell.accessoryType = .detailButton
            return cell
        }.addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(String.self)
        .subscribe(onNext: {[weak self]
            model in
            let subViewController = MultiCellTypeViewController()
            self?.navigationController?.pushViewController(subViewController, animated: true)
            print("modelSelected " + model)
        }
        ).addDisposableTo(disposeBag)
        
        tableView.rx.modelDeselected(String.self)
            .subscribe(onNext: {
                model in
                print("modelDeselected " + model)
            }
        ).addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: {
            indexPath in
                print("itemSelected " + indexPath.description)
        }).addDisposableTo(disposeBag)
        
        tableView.rx.itemDeselected
            .subscribe(onNext: {
                indexPath in
                print("itemDeselected " + indexPath.description)
        }).addDisposableTo(disposeBag)
        
        tableView.rx.itemAccessoryButtonTapped
        .subscribe(onNext: {
            indexPath in
            print("itemAccessoryButtonTapped " + indexPath.description)
        }).addDisposableTo(disposeBag)
    }
}

