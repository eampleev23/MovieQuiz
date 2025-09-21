//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 21.09.2025.
//

import Foundation

private enum Keys: String{
    // Счетчик сыгранных игр
    case gamesCount
    
    // Количество правильных ответов в лучшей игре
    case bestGameCorrect
    
    // Общее количество вопросов в лучшей игре
    case bestGameTotal
    
    // Дата лучшей игры
    case bestGameDate
    
    // Общее количество правильных ответов за все игры
    case totalCorrectAnswers
    
    // Общее количество заданных вопросов за все игры
    case totalQuestionsAsked
}

// Класс Статистик сервис отвечает за хранение общей статистики игр и реализует протокол StatisticServiceProtocol

final class StatisticService: StatisticServiceProtocol {
    
    // Свойство хранилища (чтобы вмместо "UserDefaults.standard." писать просто  "storage.")
    private let storage: UserDefaults = .standard
    
    
    // Геттер и сеттер для общего количества сыгранных игр
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    // Игра с лучшими результатами
    var bestGame: GameResult {
        
        // Геттер для игры (модель GameResult) с лучшими результатами
        get {
            GameResult(
                correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
                total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
                date: storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            )
        }
        
        // Сеттер для игры (модель GameResult) с лучшими результатами
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    // Процент угадываний
    var totalAccuracy: Double {
        get {
            
            let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
            print("totalCorrectAnswers= \(totalCorrectAnswers)")
            
            if totalCorrectAnswers == 0 {
                return 0
            }
            
            let totalQuestionsAsked = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
            print("totalQuestionsAsked= \(totalQuestionsAsked)")
            
            return Double((totalCorrectAnswers * 100) / totalQuestionsAsked)
        }
    }
    
    // Сохранение результата игры
    func store(correct count: Int, total amount: Int) {
        // Обновление количества сыгранных игр
        let gamesCountFromUD = storage.integer(forKey: Keys.gamesCount.rawValue)
        storage.set(gamesCountFromUD + 1, forKey: Keys.gamesCount.rawValue)
        
        // Обновление количества правильных ответов
        let totalCorrectAnswersFromUD = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(totalCorrectAnswersFromUD + count, forKey: Keys.totalCorrectAnswers.rawValue)
        
        // Обновление количества заданных вопросов
        let totalQuestionsAskedFromUD = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        storage.set(totalQuestionsAskedFromUD + amount, forKey: Keys.totalQuestionsAsked.rawValue)
        
        if count > bestGame.correct {
            let newRecord = GameResult(correct: count, total: amount, date: Date())
            bestGame = newRecord
        }
    }
}
