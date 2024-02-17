//
//  AlertPresenter.swift
//  MovieQuiz
//
//

import Foundation
import UIKit

final class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    
    func showAlert(controller: UIViewController, alertModel: AlertModel) {
        
        let alert = UIAlertController(title: alertModel.title, message: alertModel.text, preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion!()
        }
        
        alert.addAction(action)
        alert.view.accessibilityIdentifier = "GameResultsAlert"
        controller.present(alert, animated: true, completion: nil)
    }
}
