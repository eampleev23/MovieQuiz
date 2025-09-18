//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 18.09.2025.
//

import Foundation
import UIKit

final class AlertPresenter {
    
    // Таким образом, название метода осталось как в MovieQuizViewController, но
    // если раньше получали только QuizResultsViewModel, то сейчас получаем UIViewController и модель AlertModel.
    
    func show(in vc: UIViewController, model:AlertModel) {
        // по классике создаем алерт и берем заголовок и сообщение из модели
        let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
        
        // по классике создаем кнопку и программируем вызов замыкания в результате нажатия
        let action = UIAlertAction(title: model.buttonText, style: .default) { _ in
            model.completion()
        }
        
        // связываем алерт с экшеном
        alert.addAction(action)
        
        // показываем алерт
        vc.present(alert, animated: true, completion: nil)
    }

}
