import UIKit

final class MovieQuizViewController: UIViewController {
    
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
    private var presenter: MovieQuizPresenter!
    private var alertPresenter = AlertPresenter()
    private var statisticService: StatisticServiceProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statisticService = StatisticService()
        print("Создали statisticService и запускаем конструктор presenter")
        presenter = MovieQuizPresenter(viewController: self)
    }
    
    func btnsSwitchOn(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
        
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        btnsSwitchOn(false)
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        btnsSwitchOn(false)
        presenter.noButtonClicked()
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator(){
        activityIndicator.isHidden = true
    }
    
    func showError(message: String) {
        
        hideLoadingIndicator()
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать снова",
            identifier: "errorAlert") { [weak self] in
                guard let self = self else {return}
                presenter.restartGame()
            }
        
        alertPresenter.show(in: self, model: model)
    }
    
    func show(quiz result: QuizResultsViewModel){
        
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText, identifier: "roundResults") { [weak self] in
            guard let self = self else {return}
            presenter.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    func show(quiz step:QuizStepViewModel){
        
        print("Попали в MovieQuizViewController show(quiz step:QuizStepViewModel)")
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        print("Отображаем все сразу через 3 сек, т.е. по завершению работы функции show")
        sleep(3)
    }
    
    func showAnswerResult(isCorrect: Bool) {
        
        presenter.didAnswer(isCorrect: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 16
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeForShowBorder){ [weak self] in
            
            guard let self else { return }
            self.imageView.layer.borderWidth = 0
            self.presenter.showNextQuestionOrResults()
            self.presenter.statisticService = self.statisticService
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func hideLoadIndicator() {
        activityIndicator.isHidden = true
    }
    
    private func showNextQuestionOrResults(){
        
        if presenter.isLastQuestion() {
            
            statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            self.presenter.statisticService = self.statisticService
            presenter.showNextQuestionOrResults()
            
        } else {
            presenter.switchToNextQuestion()
        }
    }
}
