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

    private let backgroundImage: UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.contentMode = .scaleToFill
        sv.backgroundColor = .clear
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let scrollContentView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let topBox: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "DXPnMStd-Regular", size: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var editBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "to_edit_white"), for: .normal)
        btn.imageView?.contentMode = .scaleAspectFit
        btn.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(editBtnTouchOn), for: .touchDown)
        return btn
    }()

    private let bottomBox: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let questionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "DXPnMStd-Regular", size: 18)
        label.numberOfLines = 0
        label.textAlignment = .justified
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let answerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont(name: "DXPnMStd-Regular", size: 17)
        label.backgroundColor = .clear
        label.numberOfLines = 0
        label.textAlignment = .natural
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

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

        let btnItem = UIBarButtonItem(title: "수정", style: .done, target: self, action: #selector(editBtnTouchOn(_:)))
        navigationItem.rightBarButtonItem = btnItem
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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

    override func setAutoLayout() {
        super.setAutoLayout()

        setScrollView()

        view.addSubview(backgroundImage)
        view.addSubview(scrollView)

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
        setTopBox()
        setBottomBox()

        scrollContentView.addSubview(topBox)
        scrollContentView.addSubview(bottomBox)
        scrollView.addSubview(scrollContentView)

        [

            topBox.topAnchor.constraint(equalTo: scrollContentView.topAnchor, constant: 40),
            topBox.leadingAnchor.constraint(equalTo: scrollContentView.leadingAnchor, constant: 33),
            topBox.trailingAnchor.constraint(equalTo: scrollContentView.trailingAnchor, constant: -33),
            topBox.heightAnchor.constraint(equalToConstant: 55),

            bottomBox.topAnchor.constraint(equalTo: topBox.bottomAnchor, constant: 45),
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

    private func setTopBox() {
        topBox.addSubview(dateLabel)
        topBox.addSubview(editBtn)

        [
            dateLabel.topAnchor.constraint(equalTo: topBox.topAnchor, constant: 5),
            dateLabel.bottomAnchor.constraint(equalTo: topBox.bottomAnchor, constant: -5),
            dateLabel.leadingAnchor.constraint(equalTo: topBox.leadingAnchor, constant: 20),
            dateLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),

            editBtn.topAnchor.constraint(equalTo: topBox.topAnchor, constant: 5),
            editBtn.bottomAnchor.constraint(equalTo: topBox.bottomAnchor, constant: -5),
            editBtn.trailingAnchor.constraint(equalTo: topBox.trailingAnchor, constant: -10),
            editBtn.widthAnchor.constraint(lessThanOrEqualToConstant: 35),
            editBtn.widthAnchor.constraint(greaterThanOrEqualToConstant: 20)

        ].forEach { $0.isActive = true }

    }

    private func setBottomBox() {
        bottomBox.addSubview(questionLabel)
        bottomBox.addSubview(answerLabel)

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
        topBox.isHidden = true
        bottomBox.isHidden = true
    }

    override func onLoadingSuccess() {
        guard self.article != nil else {
            state = .failure
            return
        }
        super.onLoadingSuccess()
        topBox.isHidden = false
        bottomBox.isHidden = false
        showArticle()
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
                self.state = .success
            }
        }

    }

    private func showArticle() {
        guard let article = self.article else {
            state = .failure
            return
        }
        dateLabel.text = dateToStr(article.date, "M월 d일")
        answerLabel.text = article.answer

        let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
        style.lineSpacing = 10
        let attr = [NSAttributedString.Key.paragraphStyle: style]
        questionLabel.attributedText = NSAttributedString(string: article.question, attributes: attr)
        answerLabel.attributedText = NSAttributedString(string: article.answer, attributes: attr)

        if article.imagePath == "" {
            backgroundImage.image = UIImage(named: "catcat0")
        } else {
            backgroundImage.image = getUIImageFromDocDir(fileName: article.imagePath)
        }
    }

    @objc func editBtnTouchOn(_ sender: UIButton) {
        guard let date = article?.date else { return }
        let todayVC = todayViewControllerFactory(date)
        navigationController?.pushViewController(todayVC, animated: true)
    }
}
