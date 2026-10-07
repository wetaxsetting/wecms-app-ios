//
//  ElectronicTaxVC.swift
//  warBookScreen
//
//  Created by kimlang on 3/27/23.
//

import UIKit

protocol EInvoiceDelagate {
    func setData(eInvoice: EInvoiceModel?)
}

enum EINVOICE_TYPE {
    case WITH_HOLDING_INVOICE
    case EINVOICE
}

class EInvoiceVC: UIViewController {
    
    //Check button
    @IBOutlet weak var checkBtn         : UIButton!
    @IBOutlet weak var lblNoEInvoice    : UILabel!
    @IBOutlet weak var viewNoEInvoice   : UIView!
    
    var nextButton      = UIButton()
    
    var eInvoiceVM      = EInvoiceVM()
    var delegates       : EInvoiceDelagate?
    var index           : Int = 0
    var receiptList     : MREC_R006.RESPONSE.REC?
    var recFilteredData : [LIST_POP_UP_RESPONSE.REC] = []
    var eInvoiceList    : [MREC_R060.RESPONSE.REC]?
    var eInvoiceData    : [EInvoiceModel]?
    
    lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.makeLayout())
        collectionView.register(UINib(nibName: "EInvoiceCell", bundle: nil), forCellWithReuseIdentifier: "EInvoiceCell")
        collectionView.delegate     = self
        collectionView.dataSource   = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewNoEInvoice.isHidden = true
        
        self.view.addSubview(self.nextButton)
        self.view.addSubview(self.collectionView)
        
        NSLayoutConstraint.activate([
            self.nextButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.nextButton.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.nextButton.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.nextButton.heightAnchor.constraint(equalToConstant: 50.0),
            
            self.collectionView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -80.0),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
        
        setUpNavigation()
    }
    
    private func setUpNavigation(){
        self.lblNoEInvoice.text = "e_invoice_not_found_for_matching_this_expense".localized
        self.lblNoEInvoice.getlocalizedFont()
        
        self.checkBtn.getlocalizedFont()
        self.checkBtn.setTitle("next".localized, for: .normal)
        self.checkBtn.isEnabled = false
        self.checkBtn.setTitleColor(UIColor(hexString: "#FFFFFF"), for: .disabled)
         
        self.collectionView.isHidden    = self.eInvoiceList?.count == 0 ? true : false
        self.viewNoEInvoice.isHidden    = self.eInvoiceList?.count == 0 ? false : true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBarStyle(isHidden: false, animated: animated, title: "e_invoice".localized)
    }
    
    @IBAction func checkElePress(_ sender: UIButton) {
        // DOC_ID get from DOC_ID (MREC_R006) and EINV_CON_DOC_ID get from DOC_ID (MREC_R060)
        self.eInvoiceVM.submitEInvoice(DOC_ID: self.receiptList?.DOC_ID ?? "", EINV_CON_DOC_ID: self.eInvoiceData?[self.index].docID ?? "", completion: { result in
            
            switch result {
            case .success(_):
                // Here we go:
//                self.delegates?.setData(eInvoice: self.eInvoiceData?[self.index])
                MyNotify.send(name:.reloadAfterUploadImage)
                self.popOrDismissVC()
                
            case .failure(let error):
                self.showCustomAlert(titlte: "notice".localized, message: error.localizedDescription) {}
            }
        })
    }
    
    func makeLayout() -> UICollectionViewLayout {
        
        if #available(iOS 13.0, *) {
            let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                return EInvoiceLayout.listLayout()
            }
            return layout
        } else {
            // Fallback on earlier versions
        }
        return UICollectionViewLayout()
    }
}

extension EInvoiceVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionViesw: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.eInvoiceData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EInvoiceCell", for: indexPath) as! EInvoiceCell
        cell.configCell(taxData: self.eInvoiceData?[indexPath.row] , indexPath: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // use loop for select item from VM loop (searchData[indexPath.section]) loop item in section
        for item in 0..<(self.eInvoiceData?.count ?? 0) {
            self.eInvoiceData?[item].isSelectItem = item == indexPath.item ? true : false
        }
        self.index = indexPath.item
        checkBtn.backgroundColor = UIColor(hexString: "#0069B9")
        checkBtn.titleLabel?.textColor = UIColor(hexString: "#FFFFFF")
        checkBtn.isEnabled = true
        self.collectionView.reloadData()
    }
}
