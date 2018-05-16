//
//  LableRound.swift
//  petpics
//
//  Created by Maxwell Stone on 2/25/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//

import UIKit

class LableRound: UILabel {

    override func awakeFromNib() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
    }

}
