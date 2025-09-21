//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Сергей on 05.09.2025.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
}




