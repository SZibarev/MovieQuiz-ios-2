import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionTitleLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    
    // презентер для алертов
    private var alertPresenter = AlertPresenter()
    
    // сервис статистики
    var statisticService: StatisticServiceProtocol = StatisticService()
    
    // презентер
    private var presenter: MovieQuizPresenter!
    
    // MARK: - IB Actions
    // метод вызывается, когда пользователь нажимает на кнопку "Да" 
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет" 
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    
    // MARK: - Private Methods
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    func show(quiz step: QuizStepViewModel) {
        hideLoadingIndicator() // скрываем индикатор загрузки при показе вопроса
        
        imageView.isHidden = false // показываем imageView
        imageView.image = step.image
        textLabel.isHidden = false // показываем textLabel
        textLabel.text = step.question
        textLabel.textColor = UIColor(named: "YP White")
        textLabel.numberOfLines = 0 // неограниченное количество строк
        textLabel.lineBreakMode = .byWordWrapping // перенос по словам
        
        // уменьшаем размер шрифта на маленьких экранах
        if UIScreen.main.bounds.height < 700 { // iPhone SE и подобные
            textLabel.font = UIFont(name: "YSDisplay-Medium", size: 18)
        } else {
            textLabel.font = UIFont(name: "YSDisplay-Medium", size: 23)
        }
        
        counterLabel.isHidden = false // показываем counterLabel
        counterLabel.text = step.questionNumber
        
        questionTitleLabel.isHidden = false // показываем questionTitleLabel
        
        yesButton.isHidden = false // показываем yesButton
        noButton.isHidden = false // показываем noButton
        
        // сбрасываем рамку для нового вопроса
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.cornerRadius = 20
    }
    
    // приватный метод для показа результатов раунда квиза
    // принимает вью модель QuizResultsViewModel и ничего не возвращает
    func show(quiz result: QuizResultsViewModel) {
        let message = result.text
        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.presenter.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    // приватный метод, который обрабатывает результат ответа 
    // принимает на вход булевое значение и ничего не возвращает
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor(named: "YP Green")?.cgColor : UIColor(named: "YP Red")?.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
       
       imageView.layer.cornerRadius = 20
        imageView.isHidden = true // скрываем imageView до загрузки данных
        textLabel.isHidden = true // скрываем textLabel до загрузки данных
        counterLabel.isHidden = true // скрываем counterLabel до загрузки данных
        questionTitleLabel.isHidden = true // скрываем questionTitleLabel до загрузки данных
        yesButton.isHidden = true // скрываем yesButton до загрузки данных
        noButton.isHidden = true // скрываем noButton до загрузки данных
        statisticService = StatisticService()
    }
    
    
    // MARK: - Loading State
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Error State
    func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.restartGame()
        }
        
        alertPresenter.show(in: self, model: model)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
*/
