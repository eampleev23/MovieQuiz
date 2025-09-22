//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 21.09.2025.
//

import Foundation

private enum Keys: String{
    case gamesCount
    case bestGameCorrect
    case bestGameTotal
    case bestGameDate
    case totalCorrectAnswers
    case totalQuestionsAsked
}

final class StatisticService: StatisticServiceProtocol {
    
    private let storage: UserDefaults = .standard
    
    var gamesCount: Int {
        get { storage.integer(forKey: Keys.gamesCount.rawValue) }
        set { storage.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    var bestGame: GameResult {

        get {
            GameResult(
                correct: storage.integer(forKey: Keys.bestGameCorrect.rawValue),
                total: storage.integer(forKey: Keys.bestGameTotal.rawValue),
                date: storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()
            )
        }
        
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            
            let totalCorrectAnswers = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
            
            if totalCorrectAnswers == 0 {
                return 0
            }
            
            let totalQuestionsAsked = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
            
            return Double((totalCorrectAnswers * 100) / totalQuestionsAsked)
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        
        storage.set(gamesCount + 1, forKey: Keys.gamesCount.rawValue)
        
        let totalCorrectAnswersFromUD = storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        storage.set(totalCorrectAnswersFromUD + count, forKey: Keys.totalCorrectAnswers.rawValue)
        
        let totalQuestionsAskedFromUD = storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        storage.set(totalQuestionsAskedFromUD + amount, forKey: Keys.totalQuestionsAsked.rawValue)
        
        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        
        if currentGameResult.isBetterThan(bestGame){
            bestGame = currentGameResult
        }
    }
}
