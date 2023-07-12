import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol?
    
    // MARK: - Outlet
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet weak var buttonNo: UIButton!
    @IBOutlet weak var buttonYes: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory?.requestNextQuestion()
        enableButton(is: true)
    }
    
    // MARK: - Methods
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let result = QuizStepViewModel(image: UIImage(named: model.image) ?? UIImage(),
                                       question: model.text,
                                       questionNumber: "\(currentQuestionIndex+1)/\(questionsAmount)")
        return result
    }
    
    private func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
    }
    
    private func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) {
                [weak self] in guard let self = self else { return }
                self.currentQuestionIndex = 0
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
                self.enableButton(is: true)
            }
        alertPresenter?.showAlert(alertModel)
    }
    
    private func enableButton(is enable: Bool) {
        buttonNo.isEnabled = enable
        buttonYes.isEnabled = enable
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }
        
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.previewImage.layer.borderColor = UIColor.clear.cgColor
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            let text = correctAnswers == questionsAmount ?
            "Поздравляем, Вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            let alert = QuizResultsViewModel(title: "Этот раунд окончен!",
                                             text: text,
                                             buttonText: "Сыграть ещё раз")
            show(quiz: alert)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
            enableButton(is: true)
        }
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in self?.show(quiz: viewModel)}
    }
    
    // MARK: - Action methods
    @IBAction private func noButton(_ sender: Any) {
        enableButton(is: false)
        let givenAnswer = false
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
    
    @IBAction private func yesButton(_ sender: Any) {
        enableButton(is: false)
        let givenAnswer = true
        guard let currentQuestion = currentQuestion else {
            return
        }
        showAnswerResult(isCorrect: currentQuestion.correctAnswer == givenAnswer)
    }
}
