//
//  SelectItemCollectionCell.swift
//  WeCMS_iOS
//
//  Created by Seanghay Huort on 13/3/24.
//

import UIKit

class SelectItemCollectionCell: UICollectionViewCell {

    @IBOutlet weak var itemBackView : UIView!
    @IBOutlet weak var xButton      : UIButton!
    @IBOutlet weak var itemTitle    : UILabel!
    @IBOutlet weak var currencyTitle: UILabel!
    
    override var intrinsicContentSize: CGSize {
        if self.itemTitle.intrinsicContentSize.width + self.currencyTitle.intrinsicContentSize.width > 350 {
            return CGSize(width: 350, height: 40.0)
        }else{
            return CGSize(width: self.itemTitle.intrinsicContentSize.width + self.currencyTitle.intrinsicContentSize.width + 20, height: 40.0)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemTitle.getlocalizedFont()
        xButton.getlocalizedFont()
    }
    
    func configCell(data: WeCMSStruct.RECDoc_Protocol) {
        self.itemBackView.backgroundColor = UIColor(hexString: "#ECEFF1")
        self.itemTitle.textColor          = .black
        self.currencyTitle.textColor = .black
        
        self.itemTitle.text     = "\(data.TRCO_CMENM ?? "")"
        self.currencyTitle.text = " \(data.TRCO_TRSC_CCY_CD ?? "") \(customFormatCurrency(CCY_CD: data.TRCO_TRSC_CCY_CD ?? "", amount: data.TOTL_AMT ?? ""))"
        self.xButton.isHidden   = true
    }
    
    func selectCell() {
        self.xButton.isHidden   = false
        self.xButton.setImage(UIImage(named: "head_close_white"), for: .normal)
        self.itemBackView.backgroundColor = UIColor(hexString: "#0F1FEA")
        self.itemTitle.textColor = .white
        self.currencyTitle.textColor = .white
    }
    
    func deSelectCell() {
        self.xButton.isHidden = true
        self.xButton.setImage(UIImage(named: "ic_cross_white.png"), for: .normal)
        self.itemBackView.backgroundColor = UIColor(hexString: "#ECEFF1")
        self.itemTitle.textColor = .black
        self.currencyTitle.textColor = .black
    }

}

fileprivate class RowInformation {
    var spacing: CGFloat
    var cells: [UICollectionViewCell] = [] {
        didSet {
            width = cells.reduce(0.0, { $0 + $1.intrinsicContentSize.width })
            if !cells.isEmpty {
                width += CGFloat(cells.count - 1) * spacing
            }
        }
    }
    var width: CGFloat = 0.0
    
    init(spacing: CGFloat) {
        self.spacing = spacing
    }
}

extension UICollectionView {
    func getOptimalCells(_ cells: [UICollectionViewCell], maxWidth: CGFloat) -> [UICollectionViewCell] {
        var rows: [RowInformation] = []
        let spacing = (self.collectionViewLayout
            as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0.0
        
        var cellsCopy = cells
        cellsCopy.sort(by: { $0.intrinsicContentSize.width > $1.intrinsicContentSize.width })
        
        cellsCopy.forEach { (cell) in
            var isAdded: Bool = false
            for row in rows {
                if row.width + cell.intrinsicContentSize.width + spacing < maxWidth {
                    row.cells.append(cell)
                    isAdded = true
                    break
                }
            }
            if !isAdded {
                let newRow = RowInformation(spacing: spacing)
                newRow.cells.append(cell)
                rows.append(newRow)
            }
        }
        
        cellsCopy = rows.reduce(into: [UICollectionViewCell](), { (cells, row) in
            cells.append(contentsOf: row.cells)
        })
        
        return cellsCopy
    }
}
