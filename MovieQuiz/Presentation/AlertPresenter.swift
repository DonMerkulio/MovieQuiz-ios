//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Александр Меркулов on 12.07.23.
//

import Foundation
import UIKit


final class AlertPresenter: AlertPresenterProtocol {
    private weak var viewController: UIViewController?
    
    init(delegate: UIViewController? = nil) {
        self.viewController = delegate
    }
    
    func showAlert(_ data: AlertModel) {
        let alert = UIAlertController(title: data.title,
                                      message: data.message,
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(
            title: data.buttonText,
            style: .default) { _ in data.completion()}
        
        alert.addAction(action)
        
        viewController?.present(alert, animated: true)
    }
}
