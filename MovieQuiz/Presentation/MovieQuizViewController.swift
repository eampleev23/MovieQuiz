import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var imageView: UIImageView!
    
    // Константы для магических чисел и строк
    private let initialQuestionIndex = 0
    private let initialCorrectAnswers = 0
    private let finalTitleAlert = "Этот раунд окончен!"
    private let finalBtnAlertText = "Сыграть еще раз"
    private let timeForShowBorder = 1.0
    // ----
    
    // Свойства для рефакторинга
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    // ----
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    override func viewDidLoad() {
        
        if let firstQuestion = questionFactory.requestNextQuestion() {
            
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
        super.viewDidLoad()
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        if currentQuestion.correctAnswer == true {
            showAnswerResult(isCorrect: true)
        }else{
            showAnswerResult(isCorrect: false)
        }
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        if currentQuestion.correctAnswer == false {
            showAnswerResult(isCorrect: true)
        }else{
            showAnswerResult(isCorrect: false)
        }
    }
    
    private func show (quiz result: QuizResultsViewModel){
        
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
            
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            self.currentQuestionIndex = self.initialQuestionIndex
            self.correctAnswers = self.initialCorrectAnswers
            
            if let firstQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = firstQuestion
                let viewModel = convert(model: firstQuestion)
                show(quiz: viewModel)
            }
        }
        
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    private func show(quiz step:QuizStepViewModel){
        
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func convert(model:QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
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
            guard let self = self else { return }
            self.imageView.layer.borderWidth = 0
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult(){
        
        if currentQuestionIndex == questionsAmount - 1 {
            
            // Показываем результат раунда
            
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            let viewModel = QuizResultsViewModel(
                title: finalTitleAlert,
                text: text,
                buttonText: finalBtnAlertText)
            show(quiz: viewModel)
        
        } else {
            
            // Показываем следующий вопрос
            
            currentQuestionIndex += 1
            
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                show(quiz: viewModel)
            }
        }
    }
}
