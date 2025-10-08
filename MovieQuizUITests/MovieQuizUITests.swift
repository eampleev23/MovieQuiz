//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Евгений Амплеев on 30.09.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
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
    
    @MainActor
    func testExample() throws {
        let app = XCUIApplication()
        app.launch()
    }
    
    func testIndexLabel() {
        sleep(3)
        
        
    }
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"] // Находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap() // Находим кнопку "Да" и нажимаем ее
        sleep(3)
        
        let secondPoster = app.images["Poster"] // Еще раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"] // Находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap() // Находим кнопку "Нет" и нажимаем ее
        sleep(3)
        
        let secondPoster = app.images["Poster"] // Еще раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testContentAlertAfterRaundAndSucessRoundRestart() {
        sleep(3)
        
        for _ in 0..<10{
            app.buttons["No"].tap() // Находим кнопку "Нет" и нажимаем ее
            sleep(3)
        }
        
        let alert = app.alerts["roundResults"]
        let title = alert.label
        let message = alert.staticTexts.element(boundBy: 1).label
        
        XCTAssertTrue(alert.exists)
        XCTAssertEqual(title, "Этот раунд окончен!")
        XCTAssertTrue(message.contains("Ваш результат:"))
        XCTAssertTrue(message.contains("Количество сыгранных квизов:"))
        XCTAssertTrue(message.contains("Рекорд:"))
        XCTAssertTrue(message.contains("Средняя точность:"))
        
        let resultPattern = "\\d+/\\d+"
        let resultRange = message.range(of: resultPattern, options: .regularExpression)
        XCTAssertNotNil(resultRange, "Результат должен быть в формате 'число/число'")
        
        let accuracyPattern = "\\d+%"
        let accuracyRange = message.range(of: accuracyPattern, options: .regularExpression)
        XCTAssertNotNil(accuracyRange, "Точность должна быть в формате 'число%'")
        
        let goMoreButton = alert.buttons["Сыграть еще раз"]
        XCTAssertEqual(goMoreButton.label, "Сыграть еще раз")
        
        goMoreButton.tap()
        XCTAssertFalse(alert.waitForExistence(timeout: 2))
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
    }
}
