//
//  ViewController.swift
//  19_Action
//
//  Created by haibane on 2017. 7. 24..
//  Copyright © 2017년 haibane. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Action

enum MyError: Error {
    case testError
}

enum LoginError: Error {
    case emptyEmail
    case emptyPassword
    case emptyEmailAndPassword
    case incorrectPassword
}

class ViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    @IBOutlet var voidVoidButton: UIButton!
    @IBOutlet var intIntButton: UIButton!
    @IBOutlet var idTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let voidVoidButtonAction: Action<Void, Void> = Action {
            print("Doing some work")
            return Observable.empty()
        }
        
        voidVoidButton.rx.action = voidVoidButtonAction
        
        let intIntButtonAction: Action<Int, Int> = Action { input in
            return Observable.create({ observer -> Disposable in
                if input < 0 {
                    observer.onError(MyError.testError)
                } else {
                    observer.onNext(input)
                    observer.onCompleted()
                }
                return Disposables.create()
            })
        }
        
        intIntButtonAction.elements
        .subscribe(onNext: { value in
                print(value)
        }).addDisposableTo(disposeBag)
        
        intIntButtonAction
        .errors
        .subscribe(onNext: { error in
            if case .underlyingError(let err) = error {
                print(err)
            }
        }).addDisposableTo(disposeBag)
        
        intIntButtonAction.execute(-1)
        
        intIntButton.rx.bind(to: intIntButtonAction, input: 1)
        
        configureLoginFeature()
    }
    
    func configureLoginFeature() {
        
        let loginAction: Action<(String, String), Bool> = Action { credentials in
            // loginRequest returns an Observable<Bool>
            return Observable.create({ observer -> Disposable in
                switch credentials {
                case ("", ""):
                    observer.onError(LoginError.emptyEmailAndPassword)
                case (_, ""):
                    observer.onError(LoginError.emptyPassword)
                case ("", _):
                    observer.onError(LoginError.emptyEmail)
                case (_,let password):
                    if password != "1234" {
                        observer.onError(LoginError.incorrectPassword)
                    } else {
                        observer.onNext(true)
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
            })
        }
        let loginPasswordObservable = Observable.combineLatest(idTextField.rx.text, passwordTextField.rx.text) {
            ($0!, $1!)
        }
        
        loginAction.elements
        .filter { $0 }        // only keep "true" values
            .subscribe(onNext: {[weak self] _ in
                if let strongSelf = self {
                    let alert = UIAlertController(title: "알림", message: "로그인 성공", preferredStyle: .alert)
                    var ok = UIAlertAction.Action("OK", style: .default)
                    ok.rx.action = CocoaAction {
                        print("Alert's OK button was pressed")
                        return .empty()
                    }
                    alert.addAction(ok)
                    strongSelf.present(alert, animated: true, completion: nil)
                }
            })
            .addDisposableTo(disposeBag)
        
        loginAction.errors
        .subscribe(onNext: { [weak self] error in
            if case .underlyingError(let err) = error {
                if let strongSelf = self {
                    let alert = UIAlertController(title: "에러", message: String(describing: err), preferredStyle: .alert)
                    var ok = UIAlertAction.Action("OK", style: .default)
                    ok.rx.action = CocoaAction {
                        print("Alert's OK button was pressed")
                        return .empty()
                    }
                    alert.addAction(ok)
                    strongSelf.present(alert, animated: true, completion: nil)
                }
            }
        })
        .addDisposableTo(disposeBag)
        
        loginButton.rx.tap
        .withLatestFrom(loginPasswordObservable)
        .bind(to: loginAction.inputs)
        .addDisposableTo(disposeBag)
        
        loginAction.execute(("1234", "1234"))
        .filter { $0 }        // only keep "true" values
        .subscribe(onNext: {[weak self] _ in
            if let strongSelf = self {
                let alert = UIAlertController(title: "알림", message: "로그인 성공", preferredStyle: .alert)
                var ok = UIAlertAction.Action("OK", style: .default)
                ok.rx.action = CocoaAction {
                    print("Alert's OK button was pressed")
                    return .empty()
                }
                alert.addAction(ok)
                strongSelf.present(alert, animated: true, completion: nil)
            }
        })
        .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

