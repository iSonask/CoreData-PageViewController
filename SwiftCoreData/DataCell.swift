//
//  DataCell.swift
//  SwiftCoreData
//
//  Created by Akash on 26/07/17.
//  Copyright © 2017 Akash. All rights reserved.
//

import UIKit

class DataCell: UITableViewCell {

    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblName: UILabel!
    
    var data = Data(){
        didSet{
            lblName.text = data.name
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a"
            lblDate.text = dateFormatter.string(from: data.date! as Date)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblDate.font = UIFont.systemFont(ofSize: 11)
        lblName.font = UIFont.systemFont(ofSize: 14)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
