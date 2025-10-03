//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Евгений Амплеев on 02.10.2025.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private weak var viewController: MovieQuizViewController?
    private var questionFactory: QuestionFactoryProtocol?
    
    let questionsAmount: Int = 10
    let finalTitleAlert = "Этот раунд окончен!"
    let finalBtnAlertText = "Сыграть еще раз"
    
    var correctAnswers: Int = 0
    var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    var statisticService: StatisticServiceProtocol?
    
    init(viewController: MovieQuizViewController) {
        
        print("Попали в конструктор презентера")
        
        self.viewController = viewController
        
        print("Создаем фабрику...")
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        
        print("Создали фабрику, запускаем прелоадер")
        viewController.showLoadingIndicator()
        
        print("Запускаем questionFactory?.loadData()")
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        
        print("presenter didLoadDataFromServer начинает работу")
        viewController?.hideLoadIndicator()
        
        print("questionFactory?.requestNextQuestion()")
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        print("Попали в метод презентера didReceiveNextQuestion")
        
        guard let question else {
            return
        }

        print("Занесли переданную модель вопроса в currentQuestion")
        currentQuestion = question
        
        print("конвертируем ее в модель для вьюхи")
        let viewModel = convert(model: question)
        
        print("Асинхронно вызываем метод отображения вопроса self?.viewController?.show(quiz: viewModel)")
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
//        questionFactory?.loadData()?
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
        questionFactory?.requestNextQuestion()
    }
    
    func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    

    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func didAnswer(isCorrect: Bool){
        if isCorrect {
            correctAnswers += 1
        }
    }
    
    private func didAnswer(isYes: Bool) {
        
        guard let currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func showNextQuestionOrResults(){
        
        if self.isLastQuestion() {
            
            let text = """
            Ваш результат: \(correctAnswers)/\(self.questionsAmount)
            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
            Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? "дата недоступна"))
            Средняя точность: \(String(describing: statisticService?.totalAccuracy ?? 0))%
            """
            
            let viewModel = QuizResultsViewModel(
                title: finalTitleAlert,
                text: text,
                buttonText: finalBtnAlertText)
                viewController?.show(quiz: viewModel)
            
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
}
