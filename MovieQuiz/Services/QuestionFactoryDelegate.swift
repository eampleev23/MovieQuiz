//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 17.09.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}

