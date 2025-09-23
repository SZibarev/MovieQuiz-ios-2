//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Сергей on 22.09.2025.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    // swiftlint:disable:next implicitly_unwrapped_optional
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        // это специальная настройка для тестов: если один тест не прошёл,
        // то следующие тесты запускаться не будут; и правда, зачем ждать?
        continueAfterFailure = false  
    }
    
    private func waitForDataToLoad() {
        // Ждем, пока приложение загрузится
        let exists = app.wait(for: .runningForeground, timeout: 30)
        XCTAssertTrue(exists)
        
        // Ждем, пока исчезнет индикатор загрузки
        let activityIndicator = app.activityIndicators.firstMatch
        if activityIndicator.exists {
            XCTAssertFalse(activityIndicator.waitForNonExistence(timeout: 15))
        }
        
        // Ждем, пока загрузятся данные и появится первый вопрос
        let poster = app.images["Poster"]
        XCTAssertTrue(poster.waitForExistence(timeout: 10))
    }
    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        app.launch()
        
        // Ждем, пока приложение загрузится
        let exists = app.wait(for: .runningForeground, timeout: 10)
        XCTAssertTrue(exists)
        
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testYesButton() {
        waitForDataToLoad()
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let indexLabel = app.staticTexts["index"]
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testNoButton() {
        waitForDataToLoad()
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["index"]
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testGameFinish() {
        waitForDataToLoad()
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }

        let alert = app.alerts.firstMatch
        
        // Ждем, пока алерт появится
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        waitForDataToLoad()
        
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        let alert = app.alerts.firstMatch
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }

    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
