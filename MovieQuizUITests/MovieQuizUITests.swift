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
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"] // Находим первоначальный постер
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        XCTAssertTrue(firstPoster.exists)
        app.buttons["Yes"].tap() // Находим кнопку "Да" и нажимаем ее
        sleep(3)
        let secondPoster = app.images["Poster"] // Еще раз находим постер
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertTrue(secondPoster.exists)
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
}
