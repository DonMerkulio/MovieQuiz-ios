import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    private var presenter: MovieQuizPresenter?
    private var alertPresenter: AlertPresenterProtocol?
    
    
    
    // MARK: - Outlet
    @IBOutlet weak private var indexLabel: UILabel!
    @IBOutlet weak private var previewImage: UIImageView!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var buttonNo: UIButton!
    @IBOutlet weak private var buttonYes: UIButton!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(delegate: self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Methods
    
    func show(quiz step: QuizStepViewModel) {
        indexLabel.text = step.questionNumber
        previewImage.image = step.image
        questionLabel.text = step.question
        enableButton(is: true)
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText) {
                [weak self] in guard let self = self else { return }
                self.presenter?.restartGame()
                self.showLoadingIndicator()
                self.presenter?.questionFactory?.loadData()
                self.enableButton(is: true)
            }
        alertPresenter?.showAlert(alertModel)
    }
    
    func enableButton(is enable: Bool) {
        buttonNo.isEnabled = enable
        buttonYes.isEnabled = enable
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter?.didAnswer(isCorrect: isCorrect)
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.previewImage.layer.borderColor = UIColor.clear.cgColor
            self.presenter?.showNextQuestionOrResults()
        }
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    
    // MARK: - Action methods
    @IBAction private func noButton(_ sender: Any) {
        enableButton(is: false)
        presenter?.noButton()
    }
    
    @IBAction private func yesButton(_ sender: Any) {
        enableButton(is: false)
        presenter?.yesButton()
    }
}

