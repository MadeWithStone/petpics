//
//  ButtonUnderline.swift
//  petpics
//
//  Created by Maxwell Stone on 2/26/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//

import UIKit

class ButtonUnderline: UIButton {

    override func awakeFromNib() {
        let yourAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        let attributeString = NSMutableAttributedString(string: "Privacy Policy",
                                                        attributes: yourAttributes)
        self.setAttributedTitle(attributeString, for: .normal)
    }

}
