//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Сергей on 21.09.2025.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers: Int = 0
    private var questionFactory: QuestionFactoryProtocol?
    
    init(viewController: MovieQuizViewController) {
        self.viewController = viewController
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        
        let givenAnswer = isYes
        let isCorrect = givenAnswer == currentQuestion.correctAnswer
        
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.showAnswerResult(isCorrect: isCorrect)
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            // Сохраняем статистику игры
            viewController?.statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            // Создаем расширенное сообщение со статистикой
            let currentGameText = correctAnswers == questionsAmount ?
                "Поздравляем, вы ответили на \(questionsAmount) из \(questionsAmount)!" :
                "Вы ответили на \(correctAnswers) из \(questionsAmount), попробуйте ещё раз!"
            
            let gamesCountText = "Количество сыгранных квизов: \(viewController?.statisticService.gamesCount ?? 0)"
            
            let bestGame = viewController?.statisticService.bestGame ?? GameResult(correct: 0, total: 0, date: Date())
            let bestGameText = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
            
            let averageAccuracyText = "Средняя точность: \(String(format: "%.1f", viewController?.statisticService.totalAccuracy ?? 0.0))%"
            
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
            viewController?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            viewController?.showLoadingIndicator() // показываем индикатор загрузки при запросе следующего вопроса
            questionFactory?.requestNextQuestion()
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
}
