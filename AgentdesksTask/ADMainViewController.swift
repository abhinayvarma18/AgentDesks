//
//  ViewController.swift
//  AgentdesksTask
//
//  Created by ABHINAY on 20/03/18.
//  Copyright © 2018 ABHINAY. All rights reserved.
//

import UIKit

class ADMainViewController: UIViewController {
    var mainTableView = UITableView()
    var currentLoadedDataCount:Int = 0
    let networkHandler = ADNewtworkManager.sharedInstance
    let databaseHandler = ADDatabaseHandler.sharedInstance
    var instanceArticles:[Article]? = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let articlesFromDb = databaseHandler.fetchArticlesFromDB()
        if(articlesFromDb == nil || articlesFromDb?.count == 0) {
            print("loadingMoreDataFromServer")
            if(isServerReachable()) {
                self.loadData(5)
            }else{
                print("no data in db and no internet")
            }
        }else{
            print("loadingMoreDataFromDB")
            if(articlesFromDb != nil) {
                instanceArticles = converFirstFive(articlesFromDb!)
                currentLoadedDataCount = 1
            }else{
                print("no data in db and no internet as well")
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func converFirstFive(_ articles:[ArticleDB]) -> [Article] {
        var models:[Article] = []
        
        for index in (currentLoadedDataCount * 5 ..< currentLoadedDataCount * 5 + 5) {
            let dbmodel = articles[index]
            let model = Article()
            model.title = dbmodel.value(forKey: "title") as? String
            model.desc = dbmodel.value(forKey: "desc") as? String
            model.url = dbmodel.value(forKey: "url") as? String
            model.urlToImage = dbmodel.value(forKey: "urlToImage") as? String
            models.append(model)
        }
        return models
    }
    
    override func loadView() {
        super.loadView()
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(mainTableView)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.register(UINib.init(nibName: "ADArticleCellTableViewCell", bundle: nil), forCellReuseIdentifier: "ADArticleCellTableViewCell")
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[mainTableView]|", options: [], metrics: nil, views: ["mainTableView":mainTableView]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[mainTableView]|", options: [], metrics: nil, views: ["mainTableView":mainTableView]))
    }
    
    func loadData(_ pageSize:Int) {
        ADActivityLoaderView.sharedInstance.showLoader()
        networkHandler.fetchArticles(page: currentLoadedDataCount, pageSize: pageSize, completionHandler: {(articles) in
            if(articles != nil && (articles?.isEmpty)!) {
                print("new elements in local instance added")
                self.instanceArticles = self.instanceArticles! + articles!
                DispatchQueue.main.async {
                    self.mainTableView.beginUpdates()
                    for index in (self.currentLoadedDataCount*5)..<(self.instanceArticles?.count ?? 0)! {
                        self.mainTableView.insertRows(at: [IndexPath.init(row: index, section: 0)], with: UITableViewRowAnimation.fade)
                    }
                    if((self.currentLoadedDataCount*5) == (self.instanceArticles?.count ?? 0)!){
                        self.currentLoadedDataCount += 1
                    }
                    self.mainTableView.endUpdates()
                    ADActivityLoaderView.sharedInstance.removeLoader()
                }
            }else{
                print("server returned nothing")
            }
            print("final size of array is \(self.instanceArticles?.count ?? 0)")
           
        })
    }
}


extension ADMainViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (instanceArticles?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ADArticleCellTableViewCell", for:indexPath) as! ADArticleCellTableViewCell
        cell.setupData(articleDic:instanceArticles![indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    // MARK: UITableView UIScrollView Override
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        let endScrolling: CGFloat = scrollView.contentOffset.y + scrollView.frame.size.height
        
        if(currentLoadedDataCount * 5 > (self.instanceArticles?.count ?? 0)) {
            print("I got returned safely")
            return
        }
        
        
        if (endScrolling >= scrollView.contentSize.height - 1)
        {
            let articlesFromDb = databaseHandler.fetchArticlesFromDB()
            if(articlesFromDb == nil || articlesFromDb?.count == 0 || (articlesFromDb?.count ?? 0) <= currentLoadedDataCount * 5) {
                if(isServerReachable()) {
                    print("loadingMoreDataFromServer")
                    self.loadData(5)
                }else{
                    print("no internet no db saved")
                }
            }else{
                print("loadingMoreDataFromDB")
                let models = converFirstFive(articlesFromDb!)
                if(models.count != 0) {
                    instanceArticles = instanceArticles! + models
                    self.mainTableView.beginUpdates()
                    for index in (self.currentLoadedDataCount * 5 ..< (self.instanceArticles?.count ?? 0)) {
                        self.mainTableView.insertRows(at: [IndexPath.init(row: index, section: 0)], with: UITableViewRowAnimation.fade)
                    }
                    currentLoadedDataCount += 1
                    self.mainTableView.endUpdates()
                    ADActivityLoaderView.sharedInstance.removeLoader()
                }else {
                    print("db got no value left")
                }
            }
            
        }
    }
}
