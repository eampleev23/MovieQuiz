//
//  AppError.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 29.09.2025.
//

import Foundation

enum AppError: Error, LocalizedError {
    
    case internalAppError
    case noInternetConnection
    
    var errorDescription: String? {
        switch self {
        case .internalAppError:
            return "Внутренняя ошибка приложения. Обратитесь к разработчикам."
        case .noInternetConnection:
            return "Отсутствует соединение с интернетом."
        }
    }
}
