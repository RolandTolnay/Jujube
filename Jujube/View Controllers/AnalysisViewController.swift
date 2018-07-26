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
    var maxLikes: Float = 0.0

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    actorAverages = BestPicAlgorithm.shared.getAnalysisResults()
    actorAverages.forEach {
      if $0.average > maxLikes {
        maxLikes = $0.average
      }
    }
  }
    
    @IBAction func onReanalyseTapped() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "loadingVC") as? LoadingViewController else {
            return
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return actorAverages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(with: AnalysisCell.self) {
            cell.setup(with: actorAverages[indexPath.row], forMaxLikes: maxLikes)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView()
    }
}
