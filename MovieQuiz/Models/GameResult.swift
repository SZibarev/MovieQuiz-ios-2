//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Сергей on 05.09.2025.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    // метод сравнения по количеству верных ответов
    func isBetterThan(_ another: GameResult) -> Bool {
        // Сначала сравниваем количество правильных ответов
        if correct != another.correct {
            return correct > another.correct
        }
        // Если правильных ответов одинаково, сравниваем по общему количеству вопросов
        // (меньше вопросов при том же количестве правильных = лучше)
        return total < another.total
    }
}
