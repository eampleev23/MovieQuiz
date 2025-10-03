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
        print("В фабрике инициализировали moviesLoader и delegate")
    }
    
    private var movies: [MostPopularMovie] = []
    
    func loadData() {
        print("Вызываем moviesLoader.loadMovies и передаем ему замыкание DispatchQueue.main.async")
        moviesLoader.loadMovies { [weak self] result in
            // обновляет экран
            DispatchQueue.main.async{
                print("Выполняется замыкание DispatchQueue.main.async")
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    print("Проверяем, что не пустая строка")
                    if mostPopularMovies.errorMessage != "" {
                        let err = AppError.internalAppError
                        self.delegate?.didFailToLoadData(with: err)
                    }
                    print("QuestionFactory self.movies = mostPopularMovies.items ")
                    self.movies = mostPopularMovies.items // сохраняем фильмы в нашу новую переменную
                    print("QuestionFactory Вызываем self.delegate?.didLoadDataFromServer()")
                    self.delegate?.didLoadDataFromServer() // сообщаем, что данные загрузились
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error) // сообщаем об ошибке нашему MovieQuizViewController
                }
            }
            
        }
    }
    
    func requestNextQuestion() {
        print("requestNextQuestion в QuestionFactory")
        
        print("Вызываем DispatchQueue.global().async { [weak self] in")
        
        DispatchQueue.global().async { [weak self] in
            
            print("Начинает отрабатывать DispatchQueue.global().async { [weak self] in")
            guard let self = self else { return }
            
            print("Определяем случайный нормер вопроса")
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            print("Определяем что не вышли за рамки массива")
            guard let movie = self.movies[safe: index] else { return }
            
            do {
                print("Блок do { для получения картинки")
                // При необходимости задать определенное разрешение картинки
                // let imageData = try Data(contentsOf: movie.resizedImageURL)
                print("Загружаем картинку")
                let imageData = try Data(contentsOf: movie.imageURL)
                print("Здесь уже загрузили, но пока не отобразили")
                
                print("Генерируем случайный вопрос")
                
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
                
                print("Создаем модель QuizQuestion")
                let question = QuizQuestion(imageData: imageData, text: text, correctAnswer: correctAnswer)
                
                print("Вызываем DispatchQueue.main.async { [weak self] !!! ")
                DispatchQueue.main.async { [weak self] in
                    print("Попали в переданное замыкание !!!")
                    guard let self = self else { return }
                    print("Вызываем метод презентера didReceiveNextQuestion и передаем ему модель QuizQuestion")
                    self.delegate?.didReceiveNextQuestion(question: question)
                }
                
            } catch {
                print("Failed to load image")
            }
        }
    }
}
