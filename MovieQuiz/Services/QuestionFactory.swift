//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 16.09.2025.
//

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    
    weak var delegate: QuestionFactoryDelegate?
    
    private let questions: [QuizQuestion] = [
            QuizQuestion(
                image: "The Godfather",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Dark Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Kill Bill",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Avengers",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Deadpool",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "The Green Knight",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: true),
            QuizQuestion(
                image: "Old",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "The Ice Age Adventures of Buck Wild",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Tesla",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false),
            QuizQuestion(
                image: "Vivarium",
                text: "Рейтинг этого фильма больше чем 6?",
                correctAnswer: false)
        ]
    
    // В первый раз вызывается в последней строке viewDidLoad() у MovieQuizViewController
    func requestNextQuestion() {
        
        // Если нет данных в массиве, то выполнение программы прекращается (6)
        guard let index = (0..<questions.count).randomElement() else {
            delegate?.didReceiveNextQuestion(question: nil)
            return
        }
        // Если получилось получить индекс случайного элемента на предыдущем шаге, то
        // заносим в константу question по сути модель QuizQuestion (параллельно проверка идет на наличие элемента с таким индексом в массиве) (7)
        let question = questions[safe: index]
        
        // Если получилось занести в question модель, то в случае наличия значения в свойстве delegate (а оно задалось на шаге 3), вызываем у этого значения метод
        // didReceiveNextQuestion и передаем ему в качестве параметра константу question, получившую значение на предыдущем шаге (8)
        delegate?.didReceiveNextQuestion(question: question)
    }
}
