import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    
    
    // MARK: - IB Outlets
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Private Properties
    

    
    // переменная со счётчиком правильных ответов
    private var correctAnswers = 0
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter = AlertPresenter()
    private let presenter = MovieQuizPresenter()
    
    private var statisticService: StatisticService? = StatisticServiceImplementation()
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        imageView.layer.cornerRadius = 20
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        questionFactory?.loadData()
        
    }
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        // проверка, что вопрос не nil
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
        // Включение кнопок
        presenter.setButtonsEnabled(true)
        
    }
    
    // MARK: - IB Actions
    
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
        
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
        
    }
    
    // MARK: - Public Methods
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    // MARK: - Private Methods
    //метод показа индикатора загрузки
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
/*    //метод включения кнопок
    private func setButtonsEnabled(_ isEnabled : Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
*/

    // метод вывода на экран вопроса
    private func show(quiz step: QuizStepViewModel) {
        self.imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    // метод, который меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
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
        if presenter.isLastQuestion() {
            guard let statisticService = statisticService else {return}
            
            // идём в состояние "Результат квиза"
            // Увеличиваем счетчик квизов и сохраняем лучший результат
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let text = "Вы ответили на \(String(correctAnswers)) из \(presenter.questionsAmount) \n Количество сыгранных квизов: \(statisticService.gamesCount) \n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            
            //Создание модели алерта
            let alertModel = AlertModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз!",
                completion: { [weak self] in
                    guard let self = self else { return }
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                })
            
            // Вызов метода показа модели алерта
            alertPresenter.showAlert(controller: self, alertModel: alertModel)
            
        } else {
            presenter.switchToNextQuestion()
            self.questionFactory?.requestNextQuestion()
            
        }
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            text: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
            }
        
        alertPresenter.showAlert(controller: self, alertModel: alertModel)
    }
    
    
}
