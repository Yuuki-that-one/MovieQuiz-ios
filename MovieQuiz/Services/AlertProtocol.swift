//
//  AlertProtocol.swift
//  MovieQuiz
//
//

import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(quiz result: AlertModel)
}
