//
//  AnalysisCell.swift
//  Jujube
//
//  Created by Alin Stafie-Ghilase on 26/07/2018.
//  Copyright © 2018 iQuest Technologies. All rights reserved.
//

import UIKit

class AnalysisCell: UITableViewCell {
    
    @IBOutlet weak var actor: UILabel!
    @IBOutlet weak var average: UILabel!
    
    func setup(with actorAverage: ActorAverage) {
        
        actor.text = actorAverage.actor
        average.text = String(format: "~%.1f likes", actorAverage.average)
    }
}
