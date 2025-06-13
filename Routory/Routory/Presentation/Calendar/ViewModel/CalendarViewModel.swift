//
//  CalendarViewModel.swift
//  Routory
//
//  Created by 서동환 on 6/5/25.
//

import Foundation

import RxSwift

final class CalendarViewModel {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Input (ViewController ➡️ ViewModel)
    struct Input {
        let viewDidLoad: Infallible<Void>
    }
    
    // MARK: - Output (ViewModel ➡️ ViewController)
    
    struct Output {
        
    }
    
    // MARK: - Transform (Input ➡️ Output)
    
    func tranform(input: Input) -> Output {
        
        input.viewDidLoad
            .subscribe(with: self) { owner, _ in
                
            }.disposed(by: disposeBag)
        
        return Output()
    }
    
    // MARK: - Initializer
    
    init() {
        
    }
}
