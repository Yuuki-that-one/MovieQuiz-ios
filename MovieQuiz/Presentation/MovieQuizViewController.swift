import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    
    // MARK: - IB Outlets
    
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Private Properties
     
    private var currentQuestion: QuizQuestion?
    
    var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
    
    private var statisticService: StatisticService? = StatisticServiceImplementation()
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)

        
        imageView.layer.cornerRadius = 20
        
        statisticService = StatisticServiceImplementation()
        
        showLoadingIndicator()
        
    }

    // MARK: - IB Actions
    
    // метод вызывается, когда пользователь нажимает на кнопку "Да"
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет"
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        
    }
    
    // MARK: - Public Methods
    
    //метод показа индикатора загрузки
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    // метод вывода на экран вопроса
    func show(quiz step: QuizStepViewModel) {
        self.imageView.layer.borderWidth = 0
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    func show(quiz result: QuizResultsViewModel) {
        var message = result.text
        if let statisticService = statisticService {
            // Увеличиваем счетчик квизов и сохраняем лучший результат
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
            
            let text = "Вы ответили на \(String(presenter.correctAnswers)) из \(presenter.questionsAmount) \n Количество сыгранных квизов: \(statisticService.gamesCount) \n Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString)) \n Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
            message = text
        }
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            text: message,
            buttonText: "Сыграть еще раз!",
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.restartGame()
            })
        
        // Вызов метода показа модели алерта
        alertPresenter.showAlert(controller: self, alertModel: alertModel)
    }
    
    
    // метод, который меняет цвет рамки
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResults()
            
        }
    }
    
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            text: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                
                self.presenter.restartGame()
            }
        
        alertPresenter.showAlert(controller: self, alertModel: alertModel)
    }
    
    
}
