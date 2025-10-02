//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 02.10.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    func yesButtonClicked() {
        guard let currentQuestion else {
            return
        }
        
        if currentQuestion.correctAnswer == true {
            viewController?.showAnswerResult(isCorrect: true)
        }else{
            viewController?.showAnswerResult(isCorrect: false)
        }
        
    }
    
    func noButtonClicked() {
        guard let currentQuestion else {
            return
        }
        
        if currentQuestion.correctAnswer == false {
            viewController?.showAnswerResult(isCorrect: true)
        }else{
            viewController?.showAnswerResult(isCorrect: false)
        }
        
    }
}
