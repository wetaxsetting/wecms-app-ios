//
//  FileTypeCell.swift
//  WeCMS_iOS
//
//  Created by Bong Kokkheang on 11/1/24.
//

import UIKit

class FileTypeCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var docxView: UIView!
    @IBOutlet weak var pdfView: UIView!
    @IBOutlet weak var xlssView: UIView!
    @IBOutlet weak var pptxView: UIView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileSizeLabel: UILabel!
    @IBOutlet weak var extensionFileLabel: UILabel!
    @IBOutlet weak var dotMoreAction: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func moreButtonPressed(_ sender: Any) {
        
    }
    
    func config(data: FileModel) {
        fileNameLabel.text = data.fileName.removingPercentEncoding
        dotMoreAction.setImage(UIImage(named: "ico_bin"), for: .normal)
        let filename: NSString = data.fileName.removingPercentEncoding! as NSString
        let pathExtention = filename.pathExtension
        fileNameLabel.text = data.fileName.removingPercentEncoding
        fileSizeLabel.text = "\(data.fileSize.bytesToKilobytes) KB"
        docxView.isHidden = pathExtention != "docx"
        pdfView.isHidden = pathExtention != "pdf"
        xlssView.isHidden = pathExtention != "xlsx"
        pptxView.isHidden = pathExtention != "pptx"
    }
    
    func MREC_BLTB_0005_R002_0005_R001_0002_R003(data: WeCMSStruct.REC_Protocol) {
        let filename: NSString = data.ORG_FILE_NM! as NSString
        let pathExtention = filename.pathExtension
        fileNameLabel.text = data.ORG_FILE_NM
        fileSizeLabel.text = "\(data.FILE_SIZE?.bytesToKilobytes ?? "") KB"
        docxView.isHidden = pathExtention != "docx"
        pdfView.isHidden = pathExtention != "pdf"
        xlssView.isHidden = pathExtention != "xlsx"
        pptxView.isHidden = pathExtention != "pptx"
    }
}
