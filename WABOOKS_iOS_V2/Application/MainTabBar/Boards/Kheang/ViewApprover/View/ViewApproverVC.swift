//
//  ViewApproverVC.swift
//  WABOOKS_iOS_V2
//
//  Created by Kimlang on 31/1/24.
//

import UIKit

class ViewApproverVC: UIViewController {
    
    //MARK: - @IBOutlet---------------
    @IBOutlet weak var navigationView   : UIView!
    @IBOutlet weak var collectionView   : UICollectionView!
    @IBOutlet weak var titleLabel       : UILabel!
    //MARK: - VARIABLE---------------
    var approver            = ApproverVM()
    
    var BLTB_CD                     : String = ""
    var SRCH_WD                     : String = "" //BLTB_NAME LIKE
    var POST_SEQ_NO                 : String = ""
    var indexSelected : Int  = 0
    var requestorName = ""
    var requetorProfile = ""
    
    //    var ExpenseVM    = ExpenseApprovalVM()
    var APPROVER_REC: [WABOOKSStruct.REC3_Protocol]?
    
    //MARK: - LifeCircle----------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initCollectionView()
        approver.data = APPROVER_REC ?? []
        
        approver.getData()
        collectionView.isScrollEnabled = false
        collectionView.reloadData()
        
    }
    
    func initCollectionView() {
        collectionView.delegate     = self
        collectionView.dataSource   = self
        titleLabel.text = "approvers".localized
        titleLabel.getlocalizedFont()
        collectionView.collectionViewLayout = self.makeLayout()
        collectionView.register(UINib(nibName: "ApproverCell", bundle: nil), forCellWithReuseIdentifier: "ApproverCell")
        collectionView.register(UINib(nibName: "RequestorCell", bundle: nil), forCellWithReuseIdentifier: "RequestorCell")
    }
    
    //MARK: - Function----------------
    func makeLayout() -> UICollectionViewLayout {
        //make CollectionView Layout
        if #available(iOS 13.0, *) {
            let layout  = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                if section == 0 {
                    return ViewApproverLayout.requestorLayout()
                } else {
                    return ViewApproverLayout.listLayout(data: self.approver.cells[section - 1])
                }
            }
            return layout
        }
    }
}

//MARK: - UICollectionViewDataSource----------------
extension ViewApproverVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.approver.cells.count + 1
    }
    
    func collectionView(_ collectionViesw: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RequestorCell", for: indexPath) as! RequestorCell
            cell.requestorNameLabel.text = self.requestorName
            cell.img.sd_setImage(with: self.requetorProfile.formatFileURL,  completed: { (image, error, SDImageCacheType , url) in
                if error == nil {
                    cell.img.image  = image
                } else {
                    cell.img.image  = UIImage(named: "head_employee_ico")
                }
            })
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ApproverCell", for: indexPath) as! ApproverCell
            cell.configCell(data: approver.cells[indexPath.section - 1], index: indexPath.section)
            return cell
        }
    }
}
