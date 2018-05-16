//
//  ButtonRound.swift
//  petpics
//
//  Created by Maxwell Stone on 1/4/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//

import UIKit

class ButtonRound: UIButton {

    override func awakeFromNib() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 15
    }

}
