//
//  Copyright © MultiColourPixel 2020
//

import Combine
import UIKit

final class GameViewController: UIViewController {

    @IBOutlet private var playerOneNameLabel: UILabel!
    @IBOutlet private var playerTwoNameLabel: UILabel!
    @IBOutlet private var playerOneColorView: UIView!
    @IBOutlet private var playerTwoColorView: UIView!
    @IBOutlet private var playerTurnLabel: UILabel!
    @IBOutlet private var gameStartButton: UIButton!
    @IBOutlet private var currentPlayerLabel: UILabel!
    @IBOutlet private var turnTakingButtonStackView: UIStackView!
    @IBOutlet private var boardColumnsStackViews: [UIStackView]!

    private var subscriptions: Set<AnyCancellable> = []

    private let viewModel = GameViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBoard()
        bind()
        viewModel.restartGame()
    }

    @IBAction private func addToColumnTap(_ sender: UIButton) {
        viewModel.takeTurn(column: sender.tag)
    }

    @IBAction private func gameResetTap(_ sender: UIButton) {
        resetBoard()
        viewModel.restartGame()
    }
}

private extension GameViewController {

    private func bind() {
        subscriptions = [

            viewModel.$isPlayable
                .receive(on: DispatchQueue.main)
                .map { !$0 }
                .assign(to: \.isHidden, on: turnTakingButtonStackView),

            viewModel.$isLoading
                .receive(on: DispatchQueue.main)
                .map { !$0 }
                .assign(to: \.isEnabled, on: gameStartButton),

            viewModel.$playerOneName
                .receive(on: DispatchQueue.main)
                .assign(to: \.text!, on: playerOneNameLabel),

            viewModel.$playerTwoName
                .receive(on: DispatchQueue.main)
                .assign(to: \.text!, on: playerTwoNameLabel),

            viewModel.$playerOneColor
                .receive(on: DispatchQueue.main)
                .assign(to: \.backgroundColor!, on: playerOneColorView),

            viewModel.$playerTwoColor
                .receive(on: DispatchQueue.main)
                .assign(to: \.backgroundColor!, on: playerTwoColorView),

            viewModel.currentPlayStatePublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.text!, on: currentPlayerLabel),

            viewModel.gameMovePublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] move in
                    self?.updateBoard(move)
                }),

            viewModel.gameOverPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] value in
                    self?.presentGameEndAlert(status: value)
                }),

            viewModel.gameErrorPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] title in
                    self?.presentErrorAlert(title: title)
                }),
        ]
    }

    func setupBoard() {
        boardColumnsStackViews.forEach { column in
            for _ in 0..<GameConstants.rows {
                column.addArrangedSubview(makeToken())
            }
        }
    }

    func resetBoard() {
        boardColumnsStackViews.forEach { column in
            column.arrangedSubviews.forEach { view in
                view.backgroundColor = .clear
            }
        }
    }

    func updateBoard(_ move: GameMove) {
        let color = (move.player == .one) ? viewModel.playerOneColor : viewModel.playerTwoColor
        let token = boardColumnsStackViews[move.indexPath.section].arrangedSubviews[move.indexPath.item]
        UIView.animate(withDuration: 0.2) {
            token.backgroundColor = color
        }
    }

    func makeToken() -> UIView {
        let token = UIView()
        NSLayoutConstraint.activate([
            token.widthAnchor.constraint(equalToConstant: 75),
            token.heightAnchor.constraint(equalToConstant: 75),
        ])
        token.backgroundColor = .clear
        token.layer.cornerRadius = 37.5
        return token
    }
}

private extension GameViewController {

    func presentErrorAlert(title: String) {
        let alert = UIAlertController(
            title: title,
            message: "Please try again",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func presentGameEndAlert(status: GameViewModel.GameEndStatus) {
        let title: String
        let message: String

        if case let .win(winner) = status {
            title = "We have a winner!"
            message = "\(winner) has won the game."
        } else {
            title = "This game has ended in a draw"
            message = "Why not try again?"
        }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
