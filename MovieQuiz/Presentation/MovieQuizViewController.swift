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
        guard let question = question else {
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
        
        // Срабатывает событие выбора одного из вариантов ответа (13)
        
        // Проверяем есть ли currentQuestion (14)
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        // Вызываем метод showAnswerResult и передаем ему бинарную информацию о правильности ответа (15)
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
        
        // На шаге 24 попадаем в этот метод и сразу занимаемся созданием алерта с информацией из переданной модели (24)
        
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
            
        // Создаем экшн (код, который будет вызван в результате нажатия единственной кнопки в алерте (25)
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            
            guard let self = self else { return }
            
            // Обнуляем текущий номер вопроса (26)
            self.currentQuestionIndex = self.initialQuestionIndex
            
            // Обнуляем счетчик правильных ответов (27)
            self.correctAnswers = self.initialCorrectAnswers
            
            // Запускаем следующий вопрос с обнуленными параметрами (соответственно новый раунд по сути) (28)
            questionFactory?.requestNextQuestion()
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
        
        // На 17 шаге попадаем в этот метод и сначала проверяем правильно ли ответил пользователь.
        // Если да, то увеличиваем счетчик правильных ответов в раунде (17)
        if isCorrect{
            correctAnswers += 1
        }
        
        // Отображаем рамку соотвеитствующего цвета (18)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 16
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        // В течение timeForShowBorder секунд
        DispatchQueue.main.asyncAfter(deadline: .now() + timeForShowBorder){ [weak self] in
            
            // Затем проверяем, что мы в себе и все ок? (19)
            guard let self = self else { return }
            
            // Если все ок, то убираем рамку (20)
            self.imageView.layer.borderWidth = 0
            
            // Вызываем метод showNextQuestionOrResults() (21)
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults(){
        
        // На 22 шаге попадаем в этот метод и делаем проверку
        // не пытаемся ли мы показать вопрос по счету больший, чем допустимо согласно свойству questionsAmount (22)
        
        if currentQuestionIndex == questionsAmount - 1 {
            
            // Показываем результат раунда (23)
            // Создаем константу с текстовым значением для алерта (23.1)
            let text = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
            
            // создаем модель QuizResultsViewModel и заполняем ее значениями (23.2)
            let viewModel = QuizResultsViewModel(
                title: finalTitleAlert,
                text: text,
                buttonText: finalBtnAlertText)
            
            // отображаем результат раунда, вызывая метод show и передавая в него заполненную модель QuizResultsViewModel(23.3)
            show(quiz: viewModel)
        
        } else {
            
            // Показываем следующий вопрос
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
}
