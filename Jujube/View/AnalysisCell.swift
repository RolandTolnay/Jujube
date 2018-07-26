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
    
    func setup(with actorAverage: ActorAverage, forMaxLikes max: Float) {
        
        actor.text = actorAverage.actor
        average.text = String(format: "~%.1f", actorAverage.average)
        average.textColor = .orange
        if actorAverage.average > (2*max)/3 {
            average.textColor = .green
        } else if actorAverage.average < max/3 {
            average.textColor = .red
        } else {
            average.textColor = .orange
        }
    }
}
