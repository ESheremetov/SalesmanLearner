//
//  GraphViewController.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 12.06.2022.
//

import UIKit

class GraphViewController: NavigationViewController {
    
    // MARK: - OUTLETS
    @IBOutlet weak var graphView: GraphView!
    
    @IBOutlet weak var titleStack: UIStackView!
    
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var solveButton: UIButton!
    
    private var pickerView: UIPickerView!
    private var inputTextField: UITextField!
    
    private var chosenLayerName: String = ""
    
    private var connections: Array<(connection: CATextLayer, first: CGPoint, second: CGPoint)> = []
    
    // MARK: - ACTIONS
    @IBAction func solveAction(_ sender: Any) {
    }
    
    @IBAction func undoAction(_ sender: Any) {
        self.presenter.undoButtonTapped()
    }
    
    @IBAction func clearAction(_ sender: Any) {
        self.presenter.clearButtonTapped()
    }
    
    @IBAction func connectAction(_ sender: Any) {
        self.presenter.modeButtonTapped(.connect, for: sender as! UIButton)
    }
    
    @IBAction func addAction(_ sender: Any) {
        self.presenter.modeButtonTapped(.add, for: sender as! UIButton)
    }
    
    
    // MARK: - VARS
    private var landscapeViewBottomConstraint: NSLayoutConstraint?
    private var landscapeViewLeadingConstraint: NSLayoutConstraint?
    
    var presenter: GraphPresenterProtocol!
    let configurator: GraphConfiguratorProtocol = GraphConfigurator()

    override func viewDidLoad() {
        super.viewDidLoad()

        configurator.configure(with: self)
        
        self.setupViews(for: self.titleStack, with: self.graphView, true)
        
        self.addExtraPortraitConstraints(self.stackButtonsToPortrait)
        self.addExtraLandscapeConstraints(self.stackButtonsToLandscape)
        
        self.setupNavigationBar()
        self.designButtons()
        
        self.graphView.setupDrawLayers()
        self.graphView.layer.cornerRadius = 15
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.drawFigure))
        tap.cancelsTouchesInView = false
        self.graphView.addGestureRecognizer(tap)
        
        pickerView = UIPickerView()
        
        pickerView.dataSource = self
        pickerView.delegate = self
        
        pickerView.backgroundColor = UIColor(named: "AccentColor")
        
        inputTextField = UITextField(frame: .zero)
        
        view.addSubview(inputTextField)
                
        inputTextField.inputView = pickerView
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate { _ in
        } completion: { _ in
            self.presenter?.redraw()
        }
    }
}

// MARK: - DRAW EXTENSION
extension GraphViewController {
    
    @objc func drawFigure(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        let tapLocation = sender.location(in: self.graphView)
        if self.graphView == self.graphView.hitTest(tapLocation, with: nil) {
            self.presenter.drawObject(at: tapLocation)
        }
    }
    
    func drawPoint(at position: CGPoint) {
        self.graphView.drawPoint(at: position)
    }
    
    func drawConnection(from firstPoint: CGPoint, to secondPoint: CGPoint, distance: CGFloat) {
        let connectionLayer = self.graphView.drawConnection(from: firstPoint, to: secondPoint, distance: distance)
        self.connections.append((connection: connectionLayer, first: firstPoint, second: secondPoint))
    }
    
    func clearView() {
        self.graphView.clear()
    }
    
    func clearAllAnimations() {
        self.graphView.clearAllAnimations()
    }
    
    func animatePosition(at point: CGPoint) {
        self.graphView.clearAllAnimations()
        self.graphView.animateItem(at: point)
    }
}

extension GraphViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 20
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let range = Array(1...20)
        return "\(range[row])"
    }
        
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.graphView.setTextLayerString(for: self.chosenLayerName, value: "\(row + 1)")
        for item in self.connections {
            if item.connection.name == self.chosenLayerName {
                self.presenter.changeConnectionDistance(CGFloat(row + 1), firstPoint: item.first, secondPoint: item.second)
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = "\(row + 1)"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 25.0)
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        label.layer.shadowOpacity = 0.7
        label.layer.shadowRadius = 1.5
        return label
    }
    
    func showPickerView(with name: String) {
        self.chosenLayerName = name
        inputTextField.becomeFirstResponder()
    }
}

// MARK: - DESIGN EXTENSION
extension GraphViewController {
    
    private func designButtons() {
        self.design(self.solveButton)
        self.design(self.addButton)
        self.design(self.connectButton)
        self.design(self.clearButton)
        self.design(self.undoButton)
    }
    
    private func design(_ button: UIButton) {
        button.layer.cornerRadius = 10
        button.layer.backgroundColor = UIColor.systemGray6.cgColor
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 1.5
    }
    
    func buttonTappedStyle(for button: UIButton, tapped: Bool) {
        if tapped {
            button.layer.backgroundColor = UIColor.systemGray4.cgColor
            button.layer.borderWidth = 1.0
        } else {
            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn) {
                button.layer.backgroundColor = UIColor.systemGray6.cgColor
                button.layer.borderWidth = 0.0
            }
        }
    }
    
    func clearButtonsStyle() {
        self.addButton.layer.backgroundColor = UIColor.systemGray6.cgColor
        self.addButton.layer.borderWidth = 0.0
        
        self.connectButton.layer.backgroundColor = UIColor.systemGray6.cgColor
        self.connectButton.layer.borderWidth = 0.0
    }
}

// MARK: - CONSTRAINT FOR ORIENTATION EXTENSION
extension GraphViewController {
    
    private func stackButtonsToLandscape() {
        self.buttonsStackView.removeFromSuperview()
        self.buttonsStackView.axis = .vertical
        
        self.landscapeViewBottomConstraint = self.graphView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -5.0)
        self.landscapeViewBottomConstraint?.isActive = true
        self.bodyTopConstraint?.constant = 20.0
        
        self.view.addSubview(self.buttonsStackView)
        self.buttonsStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        self.buttonsStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20.0).isActive = true
        self.buttonsStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20.0).isActive = true
        
        self.landscapeViewLeadingConstraint?.isActive = false
        self.landscapeViewLeadingConstraint = self.buttonsStackView.trailingAnchor.constraint(equalTo: self.graphView.leadingAnchor, constant: -10.0)
        self.landscapeViewLeadingConstraint?.isActive = true
    }
    
    private func stackButtonsToPortrait() {
        self.buttonsStackView.removeFromSuperview()
        self.buttonsStackView.axis = .horizontal
        
        self.landscapeViewLeadingConstraint?.isActive = false
        self.landscapeViewLeadingConstraint = self.graphView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0)
        self.landscapeViewLeadingConstraint?.isActive = true
        self.landscapeViewBottomConstraint?.isActive = false
        self.bodyTopConstraint?.constant = 20.0
        
        self.view.addSubview(self.buttonsStackView)
        self.buttonsStackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20.0).isActive = true
        self.buttonsStackView.topAnchor.constraint(equalTo: self.graphView.bottomAnchor, constant: 20.0).isActive = true
        self.buttonsStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20.0).isActive = true
        self.buttonsStackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20.0).isActive = true
    }
}
