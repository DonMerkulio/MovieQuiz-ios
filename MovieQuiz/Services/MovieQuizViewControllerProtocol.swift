//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Александр Меркулов on 24.07.23.
//

import Foundation



protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func showAnswerResult(isCorrect: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
}
