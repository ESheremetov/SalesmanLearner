//
//  LectureDetailViewController.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 05.06.2022.
//

import UIKit


protocol LectureDetailViewControllerProtocol {
    
    var presenter: LectureDetailPresenterProtocol! { get set }
    
    var configurator: LectureDetailConfiguratorProtocol { get }
    
    func updateTextView(with data: Array<Array<String>>)
    func generateImageElement(imageUrl: String) -> NSAttributedString?
    func generateTextElement(_ textElement: String, _ attributes: [NSAttributedString.Key : Any]) -> NSAttributedString?
}

class LectureDetailViewController: UIViewController, LectureDetailViewControllerProtocol {
    
    @IBOutlet weak var lectureTitleLabel: UILabel!
    @IBOutlet weak var lectureIdLabel: UILabel!
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.presenter.backButtonTapped()
    }
    
    @IBOutlet weak var lectureTextView: UITextView!
    
    var presenter: LectureDetailPresenterProtocol!
    let configurator: LectureDetailConfiguratorProtocol = LectureDetailConfigurator()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        configurator.configure(with: self)
        self.presenter.configureView()
        
        self.lectureTextView.delegate = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.hideLabels),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    @objc func hideLabels() {
        
        self.presenter.updateTextView()
        
        if UIDevice.current.orientation.isLandscape {
            self.lectureTitleLabel.isHidden = true
            self.lectureIdLabel.isHidden = true
        }

        if UIDevice.current.orientation.isPortrait {
            self.lectureTitleLabel.isHidden = false
            self.lectureIdLabel.isHidden = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.presenter.viewWillDismiss()
    }
}

extension LectureDetailViewController: UITextViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.frame.size.height {
            self.presenter.lectureIsDone()
        }
        
        if (scrollView.contentOffset.y <= scrollView.contentSize.height / 5) &&
            (self.lectureTitleLabel.isHidden == true) {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut) { [ weak self ] in
                guard let self = self else { return }
                self.lectureTitleLabel.isHidden = false
                self.lectureIdLabel.isHidden = false
            }
        } else if (scrollView.contentOffset.y >= scrollView.contentSize.height / 5) &&
                    (self.lectureTitleLabel.isHidden == false) {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseOut) { [ weak self ] in
                guard let self = self else { return }
                self.lectureTitleLabel.isHidden = true
                self.lectureIdLabel.isHidden = true
            }
        }
    }
}

extension LectureDetailViewController {
    
    func generateTextElement(_ textElement: String, _ attributes: [NSAttributedString.Key : Any]) -> NSAttributedString? {
        guard let textString = try? NSMutableAttributedString(
            markdown: textElement,
            options: AttributedString.MarkdownParsingOptions(
                allowsExtendedAttributes: true,
                interpretedSyntax: .inlineOnlyPreservingWhitespace,
                failurePolicy: .returnPartiallyParsedIfPossible, languageCode: nil)) else { return nil }
        
        let range = NSRange(location: 0, length: textString.string.count)
        textString.addAttributes(attributes, range: range)
        return textString
    }
    
    func generateImageElement(imageUrl: String) -> NSAttributedString? {
        let imageName = imageUrl.components(separatedBy: "=")[1]
        guard let image = UIImage(named: imageName) else { return nil }
        let imageAttachment = NSTextAttachment(image: image)
        
        let scale = image.size.width / (UIDevice.current.orientation.isLandscape ? self.lectureTextView.frame.height : self.lectureTextView.frame.width)
        imageAttachment.image = UIImage(cgImage: imageAttachment.image!.cgImage!, scale: scale, orientation: .up)

        let imageString = NSAttributedString(attachment: imageAttachment)
        return imageString
    }
    
    func updateTextView(with data: Array<Array<String>>) {
        let newAttributedString = NSMutableAttributedString()
        
        let attributes = [
            NSAttributedString.Key.font: UIFont(name: "Verdana", size: 17.0)!,
        ]
        
        for datum in data {
            for textElement in datum {
                if textElement.contains("image_id") {
                    if let imageString = self.generateImageElement(imageUrl: textElement) {
                        newAttributedString.append(imageString)
                    }
                } else {
                    if let textString = self.generateTextElement(textElement, attributes) {
                        newAttributedString.append(textString)
                    }
                }
            }
        }
        self.lectureTextView.attributedText = newAttributedString
        self.lectureTextView.textAlignment = .justified
    }
}
