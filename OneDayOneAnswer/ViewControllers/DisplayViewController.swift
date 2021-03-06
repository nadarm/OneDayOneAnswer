//
//  DisplayViewController.swift
//  OneDayOneAnswer
//
//  Created by Mihye Kim on 23/04/2020.
//  Copyright © 2020 JMJ. All rights reserved.
//

import Foundation

import UIKit

// MARK: - UIViewController

class DisplayViewController: BaseViewController {

    // MARK: - UI Properties

    private let backgroundImage: UIImageView = UIImageView()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentMode = .scaleToFill
        sv.backgroundColor = .clear
        return sv
    }()

    private let scrollContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let bottomBox: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.isHidden = true
        return view
    }()

    private let questionLabel: UILabel = UILabel()
    private let answerLabel: UILabel = UILabel()

    // MARK: - Properties

    private let todayViewControllerFactory: TodayViewControllerFactory
    private let sqldb: DataBase
    private var dateToSet: Date?
    private var article: Article?

    // MARK: - Lifecycle

    init(
        todayViewControllerFactory: @escaping TodayViewControllerFactory,
        dataBase: DataBase,
        date: Date? = nil
    ) {
        self.todayViewControllerFactory = todayViewControllerFactory
        self.sqldb = dataBase
        self.dateToSet = date
        super.init()

        bindStyles()

        let btnItem = UIBarButtonItem(title: "수정", style: .done, target: self, action: #selector(editBtnTouchOn(_:)))
        navigationItem.rightBarButtonItem = btnItem
        let backBtnItem = UIBarButtonItem(title: "취소", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem = backBtnItem
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setArticle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scrollView.contentSize.height = scrollContentView.frame.height
    }

    // MARK: - Functions

    private func bindStyles() {
        _ = self.backgroundImage
            |> defaultBackgroundImageViewStyle()

        _ = self.questionLabel
            |> defaultLabelStyle(fontSize: 18)

        _ = self.answerLabel
            |> defaultLabelStyle(fontSize: 17)

    }

    override func setAutoLayout() {
        super.setAutoLayout()

        setScrollView()

        view.addSubview(backgroundImage)
        view.addSubview(scrollView)

        self.backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        self.scrollView.translatesAutoresizingMaskIntoConstraints = false

        [
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)

        ].forEach { $0.isActive = true }
    }

    private func setScrollView() {
        setBottomBox()

        scrollContentView.addSubview(bottomBox)
        scrollView.addSubview(scrollContentView)

        self.bottomBox.translatesAutoresizingMaskIntoConstraints = false
        self.scrollContentView.translatesAutoresizingMaskIntoConstraints = false

        [
            bottomBox.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 40),
            bottomBox.bottomAnchor.constraint(equalTo: answerLabel.bottomAnchor, constant: 30),
            bottomBox.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 33),
            bottomBox.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -33),

            scrollContentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollContentView.bottomAnchor.constraint(equalTo: bottomBox.bottomAnchor, constant: 30),
            scrollContentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollContentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollContentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)

        ].forEach { $0.isActive = true }
    }

    private func setBottomBox() {
        bottomBox.addSubview(questionLabel)
        bottomBox.addSubview(answerLabel)

        self.questionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.answerLabel.translatesAutoresizingMaskIntoConstraints = false

        [
            questionLabel.topAnchor.constraint(equalTo: bottomBox.topAnchor, constant: 30),
            questionLabel.leadingAnchor.constraint(equalTo: bottomBox.leadingAnchor, constant: 25),
            questionLabel.trailingAnchor.constraint(equalTo: bottomBox.trailingAnchor, constant: -25),

            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 30),
            answerLabel.leadingAnchor.constraint(equalTo: bottomBox.leadingAnchor, constant: 25),
            answerLabel.trailingAnchor.constraint(equalTo: bottomBox.trailingAnchor, constant: -25)

        ].forEach { $0.isActive = true }

    }

    override func onLoading() {
        super.onLoading()
        bottomBox.isHidden = true
    }

    override func onLoadingSuccess() {
        guard self.article != nil else {
            state = .failure
            return
        }
        super.onLoadingSuccess()
        bottomBox.isHidden = false
    }

    private func setArticle() {
        state = .loading
        if dateToSet == nil {
            dateToSet = Date()
        }
        guard let date = dateToSet else {
            state = .failure
            return
        }
        DispatchQueue.global().async { [weak self] in
            guard let `self` = self else { return }
            self.article = self.sqldb.selectArticle(date: date)
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.showArticle()
                self.state = .success
            }
        }

    }

    private func showArticle() {
        guard let article = self.article else {
            state = .failure
            return
        }
        navigationItem.title = dateToStr(article.date, "M월 d일")
        answerLabel.text = article.answer

        let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
        style.lineSpacing = 10
        let attr = [NSAttributedString.Key.paragraphStyle: style]
        questionLabel.attributedText = NSAttributedString(string: article.question, attributes: attr)
        answerLabel.attributedText = NSAttributedString(string: article.answer, attributes: attr)

        if article.imagePath == "" {
            backgroundImage.image = UIImage(named: "catcat0")
        } else {
            getUIImageFromDocDir(fileName: article.imagePath) { [weak self] image in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    self?.backgroundImage.image = image
                }
            }
        }
    }

    @objc func editBtnTouchOn(_ sender: UIButton) {
        guard let date = article?.date else { return }
        let todayVC = todayViewControllerFactory(date)
        navigationController?.pushViewController(todayVC, animated: true)
    }
}
