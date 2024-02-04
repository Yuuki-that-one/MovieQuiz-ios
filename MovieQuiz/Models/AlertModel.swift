//
//  AlertModel.swift
//  MovieQuiz
//
//

import Foundation

struct AlertModel {
    let title: String
    let text: String
    let buttonText: String
    init (title: String, text: String, buttonText: String) {
        self.title = title
        self.text = text
        self.buttonText = buttonText
    }
}
