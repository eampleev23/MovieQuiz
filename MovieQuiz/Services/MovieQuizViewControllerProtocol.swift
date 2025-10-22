//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 07.10.2025.
//

import Foundation

protocol MovieQuizViewControllerProtocol {
    func show(quiz step:QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func btnsSwitchOn(_ isEnabled: Bool)
    func showError(message: String)
}
