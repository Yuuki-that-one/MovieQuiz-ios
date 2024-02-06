import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate /*, AlertPresenterDelegate*/ {
    
    
    
    // MARK: - IB Outlets
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    // MARK: - Private Properties
    
    // переменная с индексом текущего вопроса
    private var currentQuestionIndex = 0
    
    // переменная со счётчиком правильных ответов
    private var correctAnswers = 0
    
    private let questionsAmount: Int = 10
    private let questionFactory: QuestionFactoryProtocol = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter = AlertPresenter()
    
    private var statisticService: StatisticService? = StatisticServiceImplementation()
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory.delegate = self
        questionFactory.requestNextQuestion()
        
        statisticService = StatisticServiceImplementation()
        
        
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        // Включение кнопок
        setButtonsEnabled(true)
        
    }
    
    // MARK: - IB Actions
    
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        
        // Отключение кнопок
        setButtonsEnabled(false)
        
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        // Отключение кнопок
        setButtonsEnabled(false)
        
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        
    }
    
    
    // MARK: - Private Methods
    //метод включения кнопок
    private func setButtonsEnabled(_ isEnabled : Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    // метод конвертации, который принимает моковый вопрос и возвращает вью модель для экрана вопроса
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // метод вывода на экран вопроса
    private func show(quiz step: QuizStepViewModel) {
        self.imageView.layer.borderWidth = 0
        imageView.image = step.image
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    // метод, который меняет цвет рамки
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }
    
    
    // метод для перехода к следующему вопросу или результату
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            guard let statisticService = statisticService else {return}
            
            // идём в состояние "Результат квиза"
            // Увеличиваем счетчик квизов и сохраняем лучший результат
            statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let text = "Вы ответили на \(String(correctAnswers)) из 10 \n Количество сыгранных квизов: \(statisticService.gamesCount) \n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            //Создание модели алерта
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз!",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 0
                    self.correctAnswers = 0
                    self.questionFactory.requestNextQuestion()
                })
            
            
            // Вызов метода показа модели алерта
            alertPresenter.showAlert(controller: self, alertModel: alertModel)
            
        } else {
            currentQuestionIndex += 1
            self.questionFactory.requestNextQuestion()
            
        }
    }
    
    
}
