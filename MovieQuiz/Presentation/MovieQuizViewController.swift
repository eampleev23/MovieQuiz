import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet var yesButton: UIButton!
    
    @IBOutlet var noButton: UIButton!
    
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet private var textLabel: UILabel!
    
    @IBOutlet private var imageView: UIImageView!
    
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private let initialQuestionIndex = 0
    
    private let initialCorrectAnswers = 0
    
    private let finalTitleAlert = "Этот раунд окончен!"
    
    private let finalBtnAlertText = "Сыграть еще раз"
    
    private let timeForShowBorder = 1.0
    
    private let questionsAmount: Int = 10
    
    private var questionFactory: QuestionFactoryProtocol?
    
    private var alertPresenter = AlertPresenter()
    
    private var statisticService: StatisticServiceProtocol?
    
    private var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex = 0
    
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnsSwitchOn(false)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func btnsSwitchOn(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        
        guard let question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
            self?.btnsSwitchOn(true)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showError(message: error.localizedDescription)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        btnsSwitchOn(false)
        
        guard let currentQuestion else {
            return
        }
        
        if currentQuestion.correctAnswer == true {
            showAnswerResult(isCorrect: true)
        }else{
            showAnswerResult(isCorrect: false)
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        btnsSwitchOn(false)
        
        guard let currentQuestion else {
            return
        }
        
        if currentQuestion.correctAnswer == false {
            showAnswerResult(isCorrect: true)
        }else{
            showAnswerResult(isCorrect: false)
        }
    }
    
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator(){
        activityIndicator.isHidden = true
    }
    
    private func showError(message: String) {
        
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать снова",
            identifier: "errorAlert") { [weak self] in
                guard let self = self else {return}
                self.currentQuestionIndex = self.initialQuestionIndex
                self.correctAnswers = self.initialCorrectAnswers
                questionFactory?.loadData()
            }
        
        alertPresenter.show(in: self, model: model)
    }
    
    private func show (quiz result: QuizResultsViewModel){
        
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, identifier: "roundResults") { [weak self] in
            guard let self = self else {return}
            self.currentQuestionIndex = self.initialQuestionIndex
            self.correctAnswers = self.initialCorrectAnswers
            questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    private func show(quiz step:QuizStepViewModel){
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(data: model.imageData) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    
    private func showAnswerResult(isCorrect: Bool) {
        
        if isCorrect{
            correctAnswers += 1
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 16
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeForShowBorder){ [weak self] in
            
            guard let self else { return }
            
            self.imageView.layer.borderWidth = 0
            
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults(){
        
        if currentQuestionIndex == questionsAmount - 1 {
            
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            let text = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService?.gamesCount ?? 0)
            Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 0) (\(statisticService?.bestGame.date.dateTimeString ?? "дата недоступна"))
            Средняя точность: \(String(describing: statisticService?.totalAccuracy ?? 0))%
            """
            
            let viewModel = QuizResultsViewModel(
                title: finalTitleAlert,
                text: text,
                buttonText: finalBtnAlertText)
            
            show(quiz: viewModel)
            
        } else {
            
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
}
