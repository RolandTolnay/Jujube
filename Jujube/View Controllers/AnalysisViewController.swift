//
//  AnalysisViewController.swift
//  Jujube
//
//  Created by Roland Tolnay on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import UIKit

class AnalysisViewController: UITableViewController {

    var actorAverages = [ActorAverage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BestPicAlgorithm.shared.setup(withActors: [AnalyzedActor(actor: "Phone", likeCount: 10), AnalyzedActor(actor: "Selfie", likeCount: 15), AnalyzedActor(actor: "Car", likeCount: 24), AnalyzedActor(actor: "Car", likeCount: 21)])
        actorAverages = BestPicAlgorithm.shared.getAnalysisResults() //[ActorAverage(actor: "Phone", average: 10), ActorAverage(actor: "Selfie", average: 15), ActorAverage(actor: "Car", average: 25)]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return actorAverages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(with: AnalysisCell.self) {
            cell.setup(with: actorAverages[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
}
