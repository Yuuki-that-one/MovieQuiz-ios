//
//  AlertProtocol.swift
//  MovieQuiz
//
//

import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func showAlert(quiz result: AlertModel)
    var delegate: UIViewController? {get set}
    
}



