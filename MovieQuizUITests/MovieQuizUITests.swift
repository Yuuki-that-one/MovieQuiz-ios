//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//

import XCTest

class MovieQuizUITests: XCTestCase {
    
    var app:XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["Yes"].tap() // находим кнопку `Да` и нажимаем её
        sleep(3)
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]


        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")

    }
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"] // находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation

        app.buttons["No"].tap() // находим кнопку `Нет` и нажимаем её
        sleep(3)
        
        let secondPoster = app.images["Poster"] // ещё раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]


        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")

    }
    func testGameFinish() {
        sleep(3)

        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["GameResultsAlert"]
        
        XCTAssertTrue(alert.exists)
            XCTAssertTrue(alert.label == "Этот раунд окончен!")
            XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз!")

    }
    
}