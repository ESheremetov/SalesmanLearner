//
//  LearnViewController.swift
//  SalesmanLearner
//
//  Created by Егор Шереметов on 04.06.2022.
//

import UIKit


class LearnViewController: NavigationViewController {
    
    @IBOutlet weak var lecturesTableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var searchLectureBar: UISearchBar!
    
    var presenter: LearnPresenterProtocol!
    var selectedLecture: Lecture? = nil
    
    let configurator: LearnConfiguratorProtocol = LearnConfigurator()
    
    private var lastContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurator.configure(with: self)
        self.presenter.configureView()
        
        self.lecturesTableView.register(
            UINib(nibName: LectureCellView.reusableIdentifier, bundle: nil),
            forCellReuseIdentifier: LectureCellView.reusableIdentifier
        )
        self.lecturesTableView.delegate = self
        self.lecturesTableView.dataSource = self
        
        self.setupViews(for: self.titleLabel, with: self.searchLectureBar)
        self.setupNavigationBar()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        self.searchLectureBar.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.presenter.needsPrepareFor(for: segue, sender: sender)
    }
}

extension LearnViewController: UISearchBarDelegate {
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.presenter.applySearch(filter: searchText)
    }
}


extension LearnViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.lectures.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LectureCellView = self.lecturesTableView.dequeueReusableCell(
            withIdentifier: LectureCellView.reusableIdentifier,
            for: indexPath
        ) as! LectureCellView
        
        cell.lectureTitleLabel.text = self.presenter.lectures[indexPath.row].title
        cell.lectureNumberLabel.text = "Лекция №\(self.presenter.lectures[indexPath.row].id)"
        cell.lectureIsDoneCheckBox.currentId = indexPath.row
        cell.lectureIsDoneCheckBox.isChecked = self.presenter.lectures[indexPath.row].isDone
        cell.lectureIsDoneCheckBox.addTarget(self, action: #selector(self.changeStatus(_:)), for: .valueChanged)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.lectureSelected(in: indexPath.row)
    }
    
    func updateTableView() {
        self.lecturesTableView.reloadData()
    }
    
    @objc func changeStatus(_ sender: Any) {
        guard let sender = sender as? CheckBox, let senderId = sender.currentId else { return }
        self.presenter.toggleLectureStatus(for: senderId)
    }
}

