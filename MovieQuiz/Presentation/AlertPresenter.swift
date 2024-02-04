//
//  AlertPresenter.swift
//  MovieQuiz
//
//

import Foundation

class AlertPresenter {
    
    weak var delegate: AlertPresenterDelegate?
    
    func createAlert(correct: Int, total: Int, message: String) -> AlertModel {
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            text: message,
            buttonText: "Сыграть еще раз")
        return alertModel
    }
    
}
