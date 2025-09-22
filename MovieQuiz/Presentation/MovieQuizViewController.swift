import UIKit


// MovieQuizViewController - наследник от UIViewController? + реализует протокол QuestionFactoryDelegate

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    // Лейбл для отображения текущего номера вопроса
    @IBOutlet private var counterLabel: UILabel!
    
    // Лейбл для отображения текста вопроса
    @IBOutlet private var textLabel: UILabel!
    
    // Имэйдж вью для отображения изображения афишы фильма
    @IBOutlet private var imageView: UIImageView!
    
    // Константы для магических чисел и строк
    
    // Стартовое значение номера вопроса
    private let initialQuestionIndex = 0
    
    // Стартовое значение количества правильных ответов
    private let initialCorrectAnswers = 0
    
    // Сообщение для отображения в результате раунда
    private let finalTitleAlert = "Этот раунд окончен!"
    
    // Текст на кнопке в конце раунда
    private let finalBtnAlertText = "Сыграть еще раз"
    
    // Время в секундах сколько показывать результат на каждом шаге перед автоматическим переходом к следующему вопросу квиза
    private let timeForShowBorder = 1.0
    // ----
    
    // Общее количество вопросов в раунде
    private let questionsAmount: Int = 10
    
    // Фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    
    // Класс для отображения алертов
    private var alertPresenter = AlertPresenter()
    
    // Свойство для объекта класса для сбора общей статистики игр
    private var statisticService: StatisticServiceProtocol?
    
    // Текущий вопрос в виде модели (переменная величина)
    private var currentQuestion: QuizQuestion?
    // ----
    
    // Номер отображаемого вопроса
    private var currentQuestionIndex = 0
    
    // Количество правильных ответов в текущем состоянии
    private var correctAnswers = 0
    
    // viewDidLoad - метод, который отрабатывает после загрузки приложения
    override func viewDidLoad() {
        // Сначала вызываем родительский метод (т.е. viewDidLoad метод у класса UIViewController? ) (1)
        super.viewDidLoad()
        
        // Создаем объект для сбора информации по общей статистике игр
        statisticService = StatisticService()
        
        // Создаем фабрику вопросов (2)
        let questionFactory = QuestionFactory()
        
        // Ставим себя делегатом для фабрики (3)
        questionFactory.delegate = self
        
        // Заносим созданную фабрику с собой в виде делегата к себе в свойство questionFactory (4)
        self.questionFactory = questionFactory
        
        // Обращаемся к фабрике для отображаения случайного вопроса (5)
        questionFactory.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // соответственно на шаге 9 приходим сюда
        // проверяем, что question пришел (9)
        guard let question else {
            return
        }
        
        // присваиваем свойству currentQuestion значение пришедшего question (10)
        currentQuestion = question
        
        // создаем модель для отображения вопроса (11)
        let viewModel = convert(model: question)
        
        // отображаем вопрос из главной очереди (12)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
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
        
        guard let currentQuestion else {
            return
        }
        
        if currentQuestion.correctAnswer == false {
            showAnswerResult(isCorrect: true)
        }else{
            showAnswerResult(isCorrect: false)
        }
    }
    
    private func show (quiz result: QuizResultsViewModel){
        
        let model = AlertModel(title: result.title, message: result.text, buttonText: result.buttonText) { [weak self] in
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
