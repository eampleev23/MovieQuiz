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
            DispatchQueue.main.async{
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    if mostPopularMovies.errorMessage != "" {
                        print("mostPopularMovies.errorMessage = \(mostPopularMovies.errorMessage)")
                        let err = AppError.internalAppError
                        self.delegate?.didFailToLoadData(with: err)
                    }
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
            
        }
    }
    
    func requestNextQuestion() {
        
        DispatchQueue.global().async { [weak self] in
            
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            do {
                
                let imageData = try Data(contentsOf: movie.imageURL)
                let rating = Float(movie.rating) ?? 0
                
                let possibleThresholds: [Float] = [8.1, 8.2, 8.3]
                let threshold = possibleThresholds.randomElement() ?? 7.0
                
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
