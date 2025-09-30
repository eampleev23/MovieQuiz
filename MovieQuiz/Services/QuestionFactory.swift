//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 16.09.2025.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    
    private weak var delegate: QuestionFactoryDelegate?
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            // обновляет экран
            DispatchQueue.main.async{
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.errorMessage != "" {
                        let err = AppError.internalAppError
                        self.delegate?.didFailToLoadData(with: err)
                    }
                    self.movies = mostPopularMovies.items // сохраняем фильмы в нашу новую переменную
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
            
        }
    }
    
    //    private let questions: [QuizQuestion] = [
    //            QuizQuestion(
    //                image: "The Godfather",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "The Dark Knight",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "Kill Bill",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "The Avengers",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "Deadpool",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "The Green Knight",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: true),
    //            QuizQuestion(
    //                image: "Old",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: false),
    //            QuizQuestion(
    //                image: "The Ice Age Adventures of Buck Wild",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: false),
    //            QuizQuestion(
    //                image: "Tesla",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: false),
    //            QuizQuestion(
    //                image: "Vivarium",
    //                text: "Рейтинг этого фильма больше чем 6?",
    //                correctAnswer: false)
    //        ]
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            do {
                // При необходимости задать определенное разрешение картинки
                // let imageData = try Data(contentsOf: movie.resizedImageURL)
                let imageData = try Data(contentsOf: movie.imageURL)
                let rating = Float(movie.rating) ?? 0
                
                // Случайный порог от 5.0 до 8.5 с шагом 0.5 для разнообразия
                let possibleThresholds: [Float] = [8.1, 8.2, 8.3]
                let threshold = possibleThresholds.randomElement() ?? 7.0
                
                // Случайно выбираем тип вопроса - "больше" или "меньше"
                let isGreaterThanQuestion = Bool.random()
                
                let text: String
                let correctAnswer: Bool
                
                if isGreaterThanQuestion {
                    text = "Рейтинг этого фильма больше чем \(threshold)?"
                    correctAnswer = rating > threshold
                } else {
                    text = "Рейтинг этого фильма меньше чем \(threshold)?"
                    correctAnswer = rating < threshold
                }
                
                let question = QuizQuestion(imageData: imageData, text: text, correctAnswer: correctAnswer)
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
                
            } catch {
                print("Failed to load image")
            }
        }
    }
}
