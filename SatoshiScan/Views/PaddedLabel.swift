//
//  PaddedLabel.swift
//  SatoshiScan
//
//  Created by Aman on 21/2/25.
//

import UIKit

class PaddedLabel: UILabel {
    
    var textInsets = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override var intrinsicContentSize: CGSize {
        
        let superSize = super.intrinsicContentSize
        return CGSize(
            width: superSize.width + textInsets.left + textInsets.right,
            height: superSize.height + textInsets.top + textInsets.bottom
        )
    }
}
