//
//  HomeViewController.swift
//  MC-2
//
//  Created by Stefanus Hermawan Sebastian on 07/06/22.
//

import UIKit
import Firebase
import FirebaseAuth

class HomeViewController: UIViewController {

    @IBOutlet weak var addNewForumButton: UIButton!
    
    @IBOutlet weak var forumSearchBar: UISearchBar!
    
    @IBOutlet weak var forumTableView: UITableView!
    
    var threads: [EntryForum] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        forumSearchBar.searchTextField.textColor = UIColor(red: 0.32, green: 0.32, blue: 0.32, alpha: 1.00)
        forumSearchBar.searchTextField.attributedPlaceholder = NSAttributedString (
        string: "Cari apa saja yang Anda butuhkan...",
        attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 0.32, green: 0.32, blue: 0.32, alpha: 1.00)])
        
        self.forumTableView.delegate = self
        self.forumTableView.dataSource = self
        
        self.forumTableView.estimatedRowHeight = 497.0
        self.forumTableView.rowHeight = UITableView.automaticDimension
        self.forumTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        self.forumTableView.register(UINib(nibName: "ForumTableViewCell", bundle: nil), forCellReuseIdentifier: "forumCellID")
        
        setBarTitle("Forum")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchForumData()
    }
    
    @IBAction func didTapNewNote() {
        
        guard let vc = storyboard?.instantiateViewController(identifier: "NewForum") as? AddNewForumViewController else {
            return
        }
        
        vc.completion = {
            newEntry in
            self.navigationController?.popToRootViewController(animated: true)
            forumRepo.createForum(entry: newEntry)
                    
            self.forumTableView.isHidden = false
        }
        
        vc.currEntry = nil
        vc.isEditingEntry = false
        
        vc.title = "Buat Forum"
        
        setBackBarItem()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.threads.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.00)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let forumSection = threads[(indexPath as NSIndexPath).section]
        let cell = forumTableView.dequeueReusableCell(withIdentifier: "forumCellID", for: indexPath) as! ForumTableViewCell
        
        cell.categoryForum.setTitle(forumSection.category, for: .normal)
        cell.categoryForum.setCategoryColor(forumSection.category)
        cell.dateForum.text = forumSection.date.toString("MMM d, yyyy")
        cell.titleForum.text = forumSection.forumTitle
        cell.descForum.text = forumSection.forumDesc
        
        if(forumSection.forumThumbnail == EMPTY_IMAGE){
            cell.imgForum.isHidden = true
        }
        
        let forumImgUrl = URL(string: forumSection.forumThumbnail)!
        cell.imgForum.load(url: forumImgUrl)
        
        let authorImgUrl = URL(string: forumSection.authorAvatar)!
        cell.authorImg.load(url: authorImgUrl)
        
        cell.authorName.text = forumSection.authorName
        cell.authorUsername.text = "@" + forumSection.authorUsername
        
        return cell
    }
    
    func fetchForumData() {
        
        var newEntries : [EntryForum] = []
        let group = DispatchGroup()
        group.enter()
        
        DispatchQueue.main.async {
            self.showSpinner(onView: self.view)
            forumRepo.fetchAllThreads { entryList in
                newEntries = entryList
                print(entryList)
                group.leave()
            }
        }
        
        group.notify(queue: .main){ [self] in
            removeSpinner()
            
            if(newEntries == threads){
                return
            }
            
            threads = newEntries
            
            forumTableView.dataSource = self
            forumTableView.delegate = self
            forumTableView.reloadData()
        }
        
    }
}

