//
//  ADNewtworkManager.swift
//  AgentdesksTask
//
//  Created by ABHINAY on 20/03/18.
//  Copyright © 2018 ABHINAY. All rights reserved.
//

import UIKit
import Foundation

class ADNewtworkManager: NSObject {
    static let sharedInstance = ADNewtworkManager()
    
    var databaseHandler:ADDatabaseHandler = ADDatabaseHandler.sharedInstance
    
    func fetchArticles(page:Int, pageSize:Int, completionHandler: @escaping ([Article]?) -> ())
    {
        let requestURL: NSURL = NSURL(string:  "https://newsapi.org/v2/top-headlines?country=us&category=technology&apiKey=179cc92871d244cbb50b7667963db1f6&pageSize=\(pageSize)&page=\(page)")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL as URL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest) {(data, response, error) -> Void in
            
            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                if let jsonObj = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary {
                    let articleArray:[Article]? = self.parseArticleData(serverData:jsonObj!)
                    if(articleArray != nil) {
                        self.databaseHandler.saveArticlesInLocalDB(articles: articleArray!,pulltorefresh:false)
                    }
                    completionHandler(articleArray)
                }
            } else {
                print("Failed")
                completionHandler(nil)
            }
        }
        task.resume()
    }
 
    func parseArticleData(serverData:NSDictionary) -> [Article]?
    {
        if let articles = serverData["articles"] as? [NSDictionary] {
            var modelArticles:[Article]? = []
            for article in articles {
                let modelArticle = Article()
                modelArticle.title = (article).value(forKey:"title") as? String ?? ""
                modelArticle.desc = (article).value(forKey:"description") as? String ?? ""
                modelArticle.url = (article).value(forKey:"url") as? String ?? ""
                modelArticle.urlToImage = (article as AnyObject).value(forKey:"urlToImage") as? String ?? ""
                modelArticles?.append(modelArticle)
            }
            return modelArticles
        }
        return nil
    }
}
