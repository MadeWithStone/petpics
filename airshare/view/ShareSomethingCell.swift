//
//  ShareSomethingCell.swift
//  PetPics

//
//  Created by Maxwell Stone on 1/2/18.
//  Copyright © 2018 Maxwell Stone. All rights reserved.
//

import UIKit
import Firebase

class ShareSomethingCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var shareBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    func configCell(imgUrl: String){
        let httpsReference = Storage.storage().reference(forURL: imgUrl)
        httpsReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print(error)
            } else {
                // Data for "images/island.jpg" is returned
                let image = UIImage(data: data!)
                self.userImageView.image = image
            }
        }
    }

}
