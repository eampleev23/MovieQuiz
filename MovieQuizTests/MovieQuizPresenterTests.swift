//
//  MovieQuizPresenterTests.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 07.10.2025.
//

import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    func show(quiz step:QuizStepViewModel){
        
    }
    func show(quiz result: QuizResultsViewModel){
        
    }
    func highlightImageBorder(isCorrectAnswer: Bool){
        
    }
    func showLoadingIndicator(){
        
    }
    func hideLoadingIndicator(){
        
    }
    func btnsSwitchOn(_ isEnabled: Bool){
        
    }
    func showError(message: String){
        
    }
}

final class MovieQuizPresenterTests: XCTestCase {
    
    func testPresenterConvertModel() {
        
        let viewControllerMock = MovieQuizViewControllerMock()
        let sut = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(imageData: emptyData, text: "Question text", correctAnswer: true)
        let viewModel = sut.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
        
    }
}
