//
//  ADArticleCellTableViewCell.swift
//  AgentdesksTask
//
//  Created by ABHINAY on 20/03/18.
//  Copyright © 2018 ABHINAY. All rights reserved.
//

import UIKit

class ADArticleCellTableViewCell: UITableViewCell {
    @IBOutlet weak var articleImage: ImageCacher!
    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var articleDescription: UILabel!
    @IBOutlet weak var articleUrl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupData(articleDic:Article!) {
        self.articleTitle.text = articleDic.title
        self.articleDescription.text = articleDic.desc
        self.articleUrl.text = articleDic.url
        self.articleImage.loadImageFromUrl(urlString:articleDic.urlToImage!)
    }
    
    
    
    
}
