//
//  QuizQuestion.swift
//  MovieQuiz
//
//  Created by Сергей on 05.09.2025.
//

import Foundation

struct QuizQuestion {
  // данные изображения фильма
  let image: Data
  // строка с вопросом о рейтинге фильма
  let text: String
  // булевое значение (true, false), правильный ответ на вопрос
  let correctAnswer: Bool
}
