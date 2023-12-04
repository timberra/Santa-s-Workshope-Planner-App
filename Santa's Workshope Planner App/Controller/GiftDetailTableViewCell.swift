//
//  GiftDetailTableViewCell.swift
//  Santa's Workshope Planner App
//
//  Created by liga.griezne on 03/12/2023.
//

import UIKit

class GiftDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var giftNameLabel: UILabel!
    @IBOutlet weak var giftPriceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
