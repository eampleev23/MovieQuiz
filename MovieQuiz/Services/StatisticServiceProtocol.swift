//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 21.09.2025.
//

import Foundation

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }
    
    func store(correct count: Int, total amount: Int)
}

struct GameResult {
    
    var correct: Int
    var total: Int
    var date: Date
    
    func isBetterThan (_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
