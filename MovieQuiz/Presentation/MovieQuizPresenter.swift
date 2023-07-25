//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Александр Меркулов on 24.07.23.
//

import Foundation
import UIKit


final class MovieQuizPresenter: QuestionFactoryDelegate {
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticService?

    weak private var viewController: MovieQuizViewControllerProtocol?
    
    var questionFactory: QuestionFactoryProtocol?
    
     
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.statisticService = StatisticServiceImplementation()
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory?.loadData()
        self.viewController?.showLoadingIndicator()
    }
    
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount
    }
    
    func restartGame() {
        correctAnswers = 0
        currentQuestionIndex = 0
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func didAnswer(isYes: Bool) {
        
        let givenAnswer = isYes
        guard let currentQuestion = currentQuestion else {
            return
        }
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    func didAnswer(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
            switchToNextQuestion()
        }
    }
    
    func noButton() {
        didAnswer(isYes: false)
    }

    func yesButton() {
        didAnswer(isYes: true)
    }
    

    func showNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let accuracy = statisticService?.totalAccuracy ?? 0
            let formattedAccuracy = String(format: "%.2f%%", accuracy)
            let text =
            """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыграных квизов: \(statisticService?.gamesCount ?? 1)
            Рекорд: \(statisticService?.bestGame.correct ?? 0)/\(statisticService?.bestGame.total ?? 10) \(statisticService?.bestGame.date.dateTimeString ?? Date().dateTimeString)
            Cредняя точность: \(formattedAccuracy)
            """
            let alert = QuizResultsViewModel(title: "Этот раунд окончен!",
                                             text: text,
                                             buttonText: "Сыграть ещё раз")
            viewController?.show(quiz: alert)
        } else {
            questionFactory?.requestNextQuestion()

        }
    }
    

    private func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        let alert = QuizResultsViewModel(title: "Что то пошло не так!",
                                         text: message,
                                         buttonText: "Попробовать ещё раз")
        viewController?.show(quiz: alert)
    }
    

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)}
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
}


