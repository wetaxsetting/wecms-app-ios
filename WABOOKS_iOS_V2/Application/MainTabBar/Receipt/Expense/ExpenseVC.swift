//
//  CompanyExpendVC.swift
//  warBookScreen
//
//  Created by kimlang on 3/21/23.
//

import UIKit

import SwiftUI

protocol SendDelagate {
    func setData(expense: [Expense]?, index: Int)
}

class ExpenseVC: UIViewController {
    
    @IBOutlet weak var nodataLbl: UILabel!
    @IBOutlet weak var noInternetView: UIView!
    @IBOutlet weak var checkBtn: UIButton!
     
    var nextButton      = UIButton()
    var ADV_PAYM_SEQ    : String?
    var index           : Int = 0
    var delegates       : SendDelagate?
    var expenseVM       = ExpenseVM()
    
    var expenseData     : [Expense]?
    var isSelectedExpense : Bool?
    
    lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.makeLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ListPaymentCell.self, forCellWithReuseIdentifier: ListPaymentCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.expenseVM.appendData()
        self.expenseData = self.expenseVM.cells
        
        checkBtn.setTitle("ok".localized, for: .normal)
        nodataLbl.text = "there_is_no_available_spending_method_please_contact_your_company_administrator".localized
        
        self.view.addSubview(self.nextButton)
        self.view.addSubview(self.collectionView)
         
        NSLayoutConstraint.activate([
            self.nextButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.nextButton.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.nextButton.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.nextButton.heightAnchor.constraint(equalToConstant: 50.0),
             
            self.collectionView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -80),
            self.collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor)
        ])
         
        setUpNavigation()
    }
    
    private func setUpNavigation(){
        self.collectionView.isHidden    = self.expenseData?.count == 0 ? true : false
        self.noInternetView.isHidden    = self.expenseData?.count == 0 ? false : true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBarStyle(isHidden: false, animated: animated, title: "payment_method".localized)
    }
    
    @IBAction func checkPress(_ sender: UIButton) {
        delegates?.setData(expense: self.expenseData, index: self.index)
        popOrDismissVC()
    }
    
    func makeLayout() -> UICollectionViewLayout {
        if #available(iOS 13.0, *) {
            let layout = UICollectionViewCompositionalLayout { (section: Int, environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                return ExpenseLayout.listLayout()
            }
            return layout
        } else {
            // Fallback on earlier versions
        }
        return UICollectionViewLayout()
    }
}


extension ExpenseVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.expenseData?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ListPaymentCell", for: indexPath) as! ListPaymentCell
        let data = self.expenseData?[indexPath.item]
        cell.configCell(listData: data, indexPath: indexPath.item)
        if data?.isSelect ?? false {
            self.index = indexPath.item
        }
        return cell

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        for item in 0..<(self.expenseData?.count ?? 0) {
            self.expenseData?[item].isSelect = item == indexPath.item ? true : false
        }
        self.index = indexPath.item
        self.collectionView.reloadData()
    }
    
}
