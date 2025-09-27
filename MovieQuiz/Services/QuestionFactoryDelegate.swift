//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 17.09.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // Сообщение об успешной загрузке
    func didFailToLoadData(with error: Error)
}
