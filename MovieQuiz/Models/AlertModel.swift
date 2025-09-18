//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 18.09.2025.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    
    let completion: () -> Void
}
