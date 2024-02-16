import UIKit

final class MovieQuizViewController: UIViewController {
    
    
    
    // MARK: - IB Outlets
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet var yesButton: UIButton!  //Кнопки блокируются через Presenter
    @IBOutlet var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Private Properties
     
    private var alertPresenter = AlertPresenter()
    private var presenter: MovieQuizPresenter!
        
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
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
        let message = presenter.makeResultsMessage()
        
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
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
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
