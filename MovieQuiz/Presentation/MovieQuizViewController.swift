import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    // MARK: - IB Outlets
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var questionTitleLabel: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    // переменная со счётчиком правильных ответов, начальное значение закономерно 0
    private var correctAnswers = 0
    
    // фабрика вопросов
    private var questionFactory: QuestionFactoryProtocol?
    
    // презентер для алертов
    private var alertPresenter = AlertPresenter()
    
    // сервис статистики
    private var statisticService: StatisticServiceProtocol = StatisticService()
    
    // презентер
    private let presenter = MovieQuizPresenter()
    
    // текущий вопрос, который видит пользователь
    private var currentQuestion: QuizQuestion?
    
    // MARK: - IB Actions
    // метод вызывается, когда пользователь нажимает на кнопку "Да" 
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true // 2
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) // 3
    }
    
    // метод вызывается, когда пользователь нажимает на кнопку "Нет" 
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false // 2
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer) // 3
    }
    
    // MARK: - Private Methods
    
    // приватный метод вывода на экран вопроса, который принимает на вход вью модель вопроса и ничего не возвращает
    private func show(quiz step: QuizStepViewModel) {
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
    private func show(quiz result: QuizResultsViewModel) {
        let message = result.text
        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter.show(in: self, model: model)
    }
    
    // приватный метод, который обрабатывает результат ответа 
    // принимает на вход булевое значение и ничего не возвращает
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect { // 1
            correctAnswers += 1 // 2
        }
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor(named: "YP Green")?.cgColor : UIColor(named: "YP Red")?.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    // приватный метод, который содержит логику перехода в один из сценариев
    // метод ничего не принимает и ничего не возвращает
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            // Сохраняем статистику игры
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            // Создаем расширенное сообщение со статистикой
            let currentGameText = correctAnswers == presenter.questionsAmount ?
                "Поздравляем, вы ответили на \(presenter.questionsAmount) из \(presenter.questionsAmount)!" :
                "Вы ответили на \(correctAnswers) из \(presenter.questionsAmount), попробуйте ещё раз!"
            
            let gamesCountText = "Количество сыгранных квизов: \(statisticService.gamesCount)"
            
            let bestGame = statisticService.bestGame
            let bestGameText = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
            
            let averageAccuracyText = "Средняя точность: \(String(format: "%.1f", statisticService.totalAccuracy))%"
            
            let fullMessage = """
            \(currentGameText)
            
            \(gamesCountText)
            \(bestGameText)
            \(averageAccuracyText)
            """
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: fullMessage,
                buttonText: "Сыграть ещё раз")
            show(quiz: viewModel)
        } else {
            presenter.switchToNextQuestion()
            showLoadingIndicator() // показываем индикатор загрузки при запросе следующего вопроса
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
       
       imageView.layer.cornerRadius = 20
        imageView.isHidden = true // скрываем imageView до загрузки данных
        textLabel.isHidden = true // скрываем textLabel до загрузки данных
        counterLabel.isHidden = true // скрываем counterLabel до загрузки данных
        questionTitleLabel.isHidden = true // скрываем questionTitleLabel до загрузки данных
        yesButton.isHidden = true // скрываем yesButton до загрузки данных
        noButton.isHidden = true // скрываем noButton до загрузки данных
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()

        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription) // возьмём в качестве сообщения описание ошибки
    }
    
    // MARK: - Loading State
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // скрываем индикатор загрузки
        activityIndicator.stopAnimating() // останавливаем анимацию
    }
    
    // MARK: - Error State
    private func showNetworkError(message: String) {
        hideLoadingIndicator() // скрываем индикатор загрузки
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
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
