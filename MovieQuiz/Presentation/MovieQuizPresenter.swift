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
    private let statisticService: StatisticServiceProtocol!
    
    init(viewController: MovieQuizViewController) {

        self.viewController = viewController
        statisticService = StatisticService()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        viewController.showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    // didLoadDataFromServer запускается после загрузки успешной загрузки данных
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    // didFailToLoadData запускается невозможности загрузить данные
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showError(message: message)
    }
    
    // didReceiveNextQuestion запускается в случае успешной загрузки данных об очередном вопросе
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }

    // isLastQuestion возвращает данные о том последний ли вопрос сейчас отображен
    func isLastQuestion() -> Bool {
        return currentQuestionIndex == questionsAmount - 1
    }
    
    // restartGame перезапускает игру
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    // switchToNextQuestion отображает следующий вопрос
    func switchToNextQuestion() {
        
        currentQuestionIndex += 1
        questionFactory?.requestNextQuestion()
    }
    
    
    // convert конвертирует модель QuizQuestion в модель QuizStepViewModel
    func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    // yesButtonClicked вызывается во вью контроллере при нажатии на кнопку да
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    // noButtonClicked вызывается во вью контроллере при нажатии на кнопку нет
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    // didAnswer вызывается только во вью контроллере
    func didAnswer(isCorrectAnswer: Bool){
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    // Отображает результаты квиза или вызывает свой switchToNextQuestion
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
        }
    }
    
    func showAnswerResult(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            
            guard let self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    // didAnswer вызывается в noButtonClicked yesButtonClicked здесь, в презентере
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        
//        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
}
