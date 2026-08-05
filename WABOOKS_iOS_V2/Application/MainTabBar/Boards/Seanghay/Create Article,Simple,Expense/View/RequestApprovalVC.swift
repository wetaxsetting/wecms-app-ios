//
//  RequestApprovalVC.swift
//  WABOOKS_iOS_V2
//
//  Created by lymanny on 10/1/25.
//
//  Note: This class was adapted from SimpleApprovalVC
//  Some conditions and methods have been modified to fit the requirements of the RequestApproval feature.

import UIKit
import IQKeyboardManagerSwift
import SDWebImage

class RequestApprovalVC: UIViewController {
    
    //MARK: - @IBOutlet
    @IBOutlet weak var tableView                        : UITableView!
    @IBOutlet weak var ApprovalNavigationTitle          : UILabel!
    @IBOutlet weak var requestButton                    : UIButton!
    @IBOutlet weak var mentionTableView                 : UITableView!
    @IBOutlet weak var mentionTableViewHC               : NSLayoutConstraint!
    @IBOutlet weak var mentionTableViewBottomConstraint : NSLayoutConstraint!
    
    //MARK: - Propertiees & Variable
    var textViewType: TextViewType  = .TITLE
    var simpleApprovalVM            = SimpleApprovalVM()
    var selectExpensesVM            = SelectExpensesVM()
    
    var requestApprovers : [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC6] = []
    var requestExpense   : [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1] = []
    
    var setFile       : [FileModel]         = []
    var imageIntPairs : [ImageFullSize]     = []
    var selectType    : SelectedExpenseType = .RECEIPT
    
    var selectDateType = "save_permanently".localized
    var indexImage     = 0
    
    var PAY_REQ_DATE          = ""
    var PAY_DATE              = ""
    var POST_TITLE            = ""
    var POST_CONT             = ""
    var PIN_POST_DUE_DT       = ""
    var POST_CONT_Formatted   = ""
    var POST_STTS             = "PL"
    var PIN_POST_TYPE         = ""
    var TOTL_AMTKHR:Double    = 0
    var TOTL_AMTUSD:Double    = 0
    var TOTL_AMTVND:Double    = 0
    var Spacing:CGFloat       = 300 // spacing between Content and Item
    var spceAfterText:CGFloat = 300
    var currentIndexImage     : Int? = 0
    
    var filterTypeBill: RowType    = .LastOneMonth //Seanghay > For date filter Bill or E-Invoice <
    var filterTypeReceipt: RowType = .LastOneMonth //Seanghay > For date filter Receipt <
    
    // max image : for choosing from gallery
    private var selectedImages          : UIImage? //image choosen from Gallary
    private var currentIndexPathImage   : IndexPath?
    var selectedContactIndexPath        : IndexPath?
    
    var receiptImage            : UIImageView?      // For Zoom animation
    
    var selectedIndex           = -1
    let mentionMemberVM         = MentionMemberVM()
    var cursorPosition          = 0
    var stringToSearch          = ""
    var mentionedMemberNames    : [String] = []
    var mentionedMembers        : [MentionMemberUIModel] = []
    var heightTitle: CGFloat    = 0
    var heightContent: CGFloat  = 0
    var keybaordHeight: CGFloat = 0
    var clientData              : [Client.ContentBody] = []
    var nickName_Purpose        = ""
    var textCount               = 0
    
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    lazy var TopBarKeyboardView : TopBarKeyboardView = {
        return Bundle.main.loadNibNamed("TopBarKeyboardView", owner: self, options: nil)?.first as! TopBarKeyboardView
    }()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.getLocalFont()
        self.registerCell()
        self.setUpView()
        
        TopBarKeyboardView.delegate = self
        mentionTableViewHC.constant = 0
        self.mentionMemberVM.initCellData(data: [])
        NotificationCenter.default.addObserver( self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil )
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        IQKeyboardManager.shared.resignOnTouchOutside = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkingNotify()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case NotifyKey.gotoPhotoPreviewVC.rawValue :
            let vc = segue.destination as! PhotoPreviewsVC
            vc.currentIndexImage = currentIndexImage
            var imgRec : [Any] = []
            for item in self.imageIntPairs {
                imgRec.append(item.image ?? UIImage())
            }
            vc.imageUrlArray      = [["RCPT_IMG_URL" : imgRec]] as Array<AnyObject>
            vc.isBtnDeleteDisable = true
        default: break
            
        }
    }
    
    //MARK: - @IBAction
    @IBAction func didTapBackAction(_ sender: Any) {
        if self.POST_TITLE.isEmpty && self.POST_CONT.isEmpty {
            self.dismiss(animated: true)
        }else {
            //Seanghay > BACK POP SAVE DRAFT < 24.JUN.2024
            let tempData1 = OptionPopupWithoutTitleModel(title: "save_draft".localized)
            let tempData2 = OptionPopupWithoutTitleModel(title: "keep_writing".localized)
            let tempData3 = OptionPopupWithoutTitleModel(title: "discard".localized)
            let data = [tempData1, tempData2, tempData3]
            // *** NOTE ***
            // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
            // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
            self.POST_CONT_Formatted = mentionedMembers.count == 0 ? self.POST_CONT : self.formatMentionFromReadableToAPISyntax(originalText: POST_CONT, mentionedMembers: mentionedMembers)
            self.switchOption(optionData: data, title: "save_as_draft?".localized, description: "draft_lets_you_edit_your_post_later_or_tap_discard_to_cancel_posting.".localized) { str in
                if str == "save_draft".localized {
                    self.createExpense(saveDraft: "Y")
                    self.dismiss(animated: true)
                }
                else if str == "discard".localized { //Seanghay > DISMISS 2 TIME TO GO BACK TO MAIN BOARD < 24.JUN.2024
                    self.dismiss(animated: true)
                    self.dismiss(animated: true)
                }
                else{
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @IBAction func didTapRequestAction(_ sender: Any) {
        
        // *** NOTE ***
        // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
        // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
        self.POST_CONT_Formatted = mentionedMembers.count == 0 ? self.POST_CONT : self.formatMentionFromReadableToAPISyntax(originalText: POST_CONT, mentionedMembers: mentionedMembers)
        self.createExpense()
    }
    
    //MARK: - Function
    func previewImage() {
        self.performSegue(withIdentifier: NotifyKey.gotoPhotoPreviewVC.rawValue, sender: nil)
    }
    
    func getLocalFont(){
        self.ApprovalNavigationTitle.getlocalizedFont()
        self.requestButton.getlocalizedFont()
    }
    
    func refreshRECORD() { //Seanghay > DELETE ALL DATA WHEN SWITCH <
        self.simpleApprovalVM.attacmentREC          = []
        self.simpleApprovalVM.attacmentArticleREC   = []
        self.imageIntPairs                          = []
        self.TOTL_AMTKHR                            = 0
        self.TOTL_AMTUSD                            = 0
        self.POST_TITLE                             = ""
        self.POST_CONT                              = ""
        self.requestApprovers                       = []
        self.simpleApprovalVM.selectApproversCount  = ""
        self.textCount                              = 0
        self.simpleApprovalVM.initDataWeCMS()
        
    }
    
    func validation() -> Bool {
        if self.POST_TITLE.isEmpty {
            self.alertError(message: "Title_must_not_be_empty.".localized)
            return false
        }else if self.POST_CONT.isEmpty {
            self.alertError(message: "content_is_required".localized)
            return false
        }else if self.requestApprovers.count == 0 {
            self.alertError(message: "Must_select_approver_to_post".localized)
            return false
        }else{
            return true
        }
    }
    
    private func registerCell() {
        self.tableView.register(UINib(nibName: "ApprovalFormHeaderCell",    bundle: nil), forCellReuseIdentifier: "ApprovalFormHeaderCell")
        self.tableView.register(UINib(nibName: "ApprovalInfoCell",          bundle: nil), forCellReuseIdentifier: "ApprovalInfoCell")
        self.tableView.register(UINib(nibName: "ApprovalInfoWeCMSCell",          bundle: nil), forCellReuseIdentifier: "ApprovalInfoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalDateInfoWeCMSCell",      bundle: nil), forCellReuseIdentifier: "ApprovalDateInfoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalSelectInfoWeCMSCell",    bundle: nil), forCellReuseIdentifier: "ApprovalSelectInfoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalLineCell",          bundle: nil), forCellReuseIdentifier: "ApprovalLineCell")
        self.tableView.register(UINib(nibName: "ImageViewWeCMSCell",             bundle: nil), forCellReuseIdentifier: "ImageViewWeCMSCell")
        self.tableView.register(UINib(nibName: "AttactMentsWeCMSCell",           bundle: nil), forCellReuseIdentifier: "AttactMentsWeCMSCell")
        self.tableView.register(UINib(nibName: "ArticleToggleCell",         bundle: nil), forCellReuseIdentifier: "ArticleToggleCell")
        self.tableView.register(UINib(nibName: "ExpenseItemCell",           bundle: nil), forCellReuseIdentifier: "ExpenseItemCell")
        self.tableView.register(UINib(nibName: "SeeMoreCell",               bundle: nil), forCellReuseIdentifier: "SeeMoreCell")
        self.tableView.register(UINib(nibName: "DocumentNoCell",            bundle: nil), forCellReuseIdentifier: "DocumentNoCell")
        self.tableView.register(UINib(nibName: "DocumentNoWeCMSCell",   bundle: nil), forCellReuseIdentifier: "DocumentNoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalSelectExpenseCell", bundle: nil), forCellReuseIdentifier: "ApprovalSelectExpenseCell")
        self.mentionTableView.register(UINib(nibName: "MentionMemberCell",  bundle: nil), forCellReuseIdentifier: "MentionMemberCell")
    }
    
    private func setUpView(){
        self.requestButton.backgroundColor = UIColor(hexString: "#0069B9")
        self.requestButton.setTitleColor(.white, for: .normal)
        self.simpleApprovalVM.initDataWeCMS()
        self.setNavView(title: "Request Approval", buttonTitle: "request".localized)
    }
    
    private func setNavView(title: String, buttonTitle: String) {
        self.ApprovalNavigationTitle.text                   = title
        self.requestButton.setTitle(buttonTitle, for: .normal)
    }
    
    private func checkingNotify() {
        MyNotify.listen(self, selector: #selector(getDataAddManual),name: .getDataAddManual)
        MyNotify.listen(self, selector: #selector(getClientData),   name: .clientData)
    }
    
    private func createApproval(saveDraft: String = "N") {
        let REC1 = self.simpleApprovalVM.requestExpense
        let REC3 = self.simpleApprovalVM.attacmentREC
        let REC6 = self.requestApprovers
        if self.validation() || saveDraft == "Y"{
            self.simpleApprovalVM.createApproval(
                body: WABOOKS_MREC_BLTB_0004_C002.REQUEST(APPR_DV          : "70",
                                                          PAY_DATE         : self.PAY_DATE,
                                                          TOT_PAY_LOC_AMT  : 0,
                                                          TOT_PAY_USD_AMT  : 0,
                                                          SAL_REG_SEQ_NO   : "",
                                                          PAYM_AMT_BYDF    : "",
                                                          PAY_REQ_DATE     : self.PAY_REQ_DATE,
                                                          REF_DATA_CNT     : nil,//"Added (2022/04/26)resl_0002_001_r001 >> TOT_CNT 값 Bypass. Table No. 1 Insert"
                                                          APLY_EXCH_RATE   : 4081,//"V2023.1.0.29 Table 1, APPR_DV = '00' : Required(Now It use only in VN version)"
                                                          DRAFT_POST_SEQ_NO: "",//It required when Open as draft
                                                          POST_TITLE       : self.POST_TITLE,
                                                          POST_APPR_DV     : "00",// "Table 9, 12", '00': Simple Approval, '10': Expense Approval"
                                                          POST_CONT        : self.POST_CONT_Formatted.convertStringToHTML,
                                                          POST_DRAFT_YN    : saveDraft, //Y: Save draft, N: Post or Request
                                                          REC1             : REC1,
                                                          REC2             : [],
                                                          REC5             : [],
                                                          REC6             : REC6,
                                                          REC3             : REC3)) { error in
                                                              if error != nil {
                                                                  self.alertError(message: error?.localizedDescription ?? "Error")
                                                              }else{
                                                                  if saveDraft == "Y" {
                                                                      let leftTitle = "saved_to_draft!".localized
                                                                      let message = "you_can_find_draft_post_in_the_board_draft".localized
                                                                      self.infoMessagePopup(iconName: "ico_check-2", title: leftTitle, message: message, confirmTitle: "okay".localized) { isOkay in
                                                                          self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                                                                              MyNotify.send(name: .reloadAfterCreateArticle, object: ["ARTICLE_TYPE": "C"] as AnyObject)
                                                                          })
                                                                          self.dismiss(animated: true)
                                                                      }
                                                                  }else{
                                                                      self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                                                                          MyNotify.send(name: .reloadAfterCreateArticle, object: ["ARTICLE_TYPE": "C"] as AnyObject)
                                                                      })
                                                                  }
                                                              }
                                                          }
        }
    }
    
    private func createExpense(saveDraft: String = "N") {
        let today               = Date()
        let dateFormatter       = DateFormatter()
        dateFormatter.dateStyle = .medium
        let formattedDate       = dateFormatter.string(from: today)
        let defaultDate         = formattedDate.formattedDateFromString(dateString: formattedDate, withFormat: "yyyyMMdd")
        let REC1                = self.simpleApprovalVM.requestExpense
        let REC3                = self.simpleApprovalVM.attacmentREC
        let REC6                = self.requestApprovers
        let TOT_LOC             = self.TOTL_AMTVND
        
        if self.validation() || saveDraft == "Y"{
            self.simpleApprovalVM.createApproval(
                body: WABOOKS_MREC_BLTB_0004_C002.REQUEST(APPR_DV          : REC1.first?.DOC_TYPE == "" ? "00" : REC1.first?.APPR_DV,
                                                          PAY_DATE         : self.PAY_DATE == "" ? defaultDate : self.PAY_DATE,
                                                          TOT_PAY_LOC_AMT  : Int(TOT_LOC),
                                                          TOT_PAY_USD_AMT  : Int(self.TOTL_AMTUSD),
                                                          SAL_REG_SEQ_NO   : "",
                                                          PAYM_AMT_BYDF    : "",
                                                          PAY_REQ_DATE     : self.PAY_REQ_DATE == "" ? defaultDate : self.PAY_REQ_DATE,
                                                          REF_DATA_CNT     : "",//"Added (2022/04/26)resl_0002_001_r001 >> TOT_CNT 값 Bypass. Table No. 1 Insert"
                                                          APLY_EXCH_RATE   : 4081,//"V2023.1.0.29 Table 1, APPR_DV = '00' : Required(Now It use only in VN version)"
                                                          DRAFT_POST_SEQ_NO: "",//It required when Open as draft
                                                          POST_TITLE       : self.POST_TITLE,
                                                          POST_APPR_DV     : "10",// "Table 9, 12", '00': Simple Approval, '10': Expense Approval"
                                                          POST_CONT        : self.POST_CONT_Formatted.convertStringToHTML,
                                                          POST_DRAFT_YN    : saveDraft, //Y: Save draft, N: Post or Request
                                                          REC1             : REC1,
                                                          REC2             : [],
                                                          REC5             : [],
                                                          REC6             : REC6,
                                                          REC3             : REC3)) { error in
                                                              if error != nil {
                                                                  self.alertError(message: error?.localizedDescription ?? "Error")
                                                              }else{
                                                                  if saveDraft == "Y" {
                                                                      let leftTitle = "saved_to_draft!".localized
                                                                      let message = "you_can_find_draft_post_in_the_board_draft".localized
                                                                      self.infoMessagePopup(iconName: "ico_check-2", title: leftTitle, message: message, confirmTitle: "okay".localized) { isOkay in
                                                                          self.dismiss(animated: true)
                                                                          self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                                                                              MyNotify.send(name: .reloadAfterCreateArticle, object: ["ARTICLE_TYPE": "C"] as AnyObject)
                                                                          })
                                                                      }
                                                                  }else{
                                                                      self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                                                                          MyNotify.send(name: .reloadAfterCreateArticle, object: ["ARTICLE_TYPE": "C"] as AnyObject)
                                                                      })
                                                                  }
                                                              }
                                                          }
        }
    }
    
    private func createNewArticle(saveDraft: String = "N") {
        let REC = self.simpleApprovalVM.attacmentArticleREC
        var REC2 : [WABOOKS_MREC_BLTB_0004_C001.REQUEST.REC2] = []
        
        // WeCMS has no bulletin boards to target, so posts always go to the default board key.
        REC2 = [WABOOKS_MREC_BLTB_0004_C001.REQUEST.REC2(BLTB_CD: "999999999999999")]
        if self.validation() || saveDraft == "Y"{
            self.simpleApprovalVM.createNewArticle(
                body: WABOOKS_MREC_BLTB_0004_C001.REQUEST(DRAFT_POST_SEQ_NO  : "",
                                                          POST_TITLE         : self.POST_TITLE,
                                                          POST_ANTH_BLTB_YN  : "N",
                                                          POST_TYPE_CD       : "01",
                                                          POST_CONT          : self.POST_CONT_Formatted.convertStringToHTML,
                                                          POST_STTS          : self.POST_STTS,
                                                          POST_DRAFT_YN      : saveDraft,
                                                          PIN_POST_TYPE      : self.PIN_POST_TYPE == "" ? nil : self.PIN_POST_TYPE,
                                                          PIN_POST_DUE_DT    : self.PIN_POST_DUE_DT == "permanently".localized ? "" : self.PIN_POST_DUE_DT,
                                                          REF_BLTB_CD        : Shared.BLTB_CD == "" ? "999999999999999" : Shared.BLTB_CD,
                                                          REF_POST_SEQ_NO    : "",
                                                          REC3               : [],
                                                          REC2               : REC2,
                                                          REC                : REC)) { error in
                                                              if error != nil {
                                                                  self.alertError(message: error?.localizedDescription ?? "Error")
                                                              }else{
                                                                  if saveDraft == "Y" {
                                                                      self.infoMessagePopup(iconName: "ico_check-2", title: "saved_to_draft!".localized, message: "you_can_find_draft_post_in_the_board_draft".localized, confirmTitle: "okay".localized) { isOkay in
                                                                          self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                                                                              MyNotify.send(name: .reloadAfterCreateArticle, object: ["ARTICLE_TYPE": "C"] as AnyObject)
                                                                          })
                                                                          self.dismiss(animated: true)
                                                                      }
                                                                  }else{
                                                                      self.view.window?.rootViewController?.dismiss(animated: true, completion: {
                                                                          MyNotify.send(name: .reloadAfterCreateArticle, object: ["ARTICLE_TYPE": "C"] as AnyObject)
                                                                      })
                                                                  }
                                                              }
                                                          }
        }
    }
    
    private func calculateTotalAmount(data:  [WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1]) { //Seanghay > CALCULATE AMOUNT EACH CURRENCY <
        self.TOTL_AMTKHR = 0
        self.TOTL_AMTUSD = 0
        self.TOTL_AMTVND = 0
        for item in data {
            if (item.CCY_CD ?? "").contains("KHR") {
                let intAMT = Double(item.AMT?.replace(of: "KHR", with: "") ?? "") ?? 0
                self.TOTL_AMTKHR += intAMT
            }
            else if (item.CCY_CD ?? "").contains("VND") {
                let intAMT = Double(item.AMT?.replace(of: "VND", with: "") ?? "") ?? 0
                self.TOTL_AMTVND += intAMT
            }
            else{
                let intAMT = Double(item.AMT?.replace(of: "USD", with: "") ?? "") ?? 0
                self.TOTL_AMTUSD += intAMT
            }
        }
    }
    
    private func goToPurpose( _ userListKey: String) {
        let vc                      = self.VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC" ) as! SelectPurposeVC
        vc.delegate                 = self
        vc.selectUserListKey        = userListKey
        vc.isShowPlanned_money      = true
        vc.isShowOnlyPlanned_money  = false
        vc.headerTitle              = "select_a_purpose".localized
        self.presetVC(vc:vc)
    }
    
    private func selectTogglePurpose(row: Int) { //Seanghay > GO TO SELECT PURPOSE by INDEX <
        self.selectedIndex          = row
        let vc                      = self.VC(sbName: "SelectPurposeSB", identifier: "SelectPurposeVC" ) as! SelectPurposeVC
        vc.delegate                 = self
        vc.selectUserListKey        = self.simpleApprovalVM.expenseApproval[row].BUSA_USAG_CD ?? ""
        vc.isShowPlanned_money      = true
        vc.isShowOnlyPlanned_money  = false
        vc.headerTitle              = "select_a_purpose".localized
        self.presetVC(vc:vc)
    }
    
    private func deleteExpenseItem(row: Int) {
        let tempData1 = OptionPopupWithoutTitleModel(title: "delete".localized)
        let tempData2 = OptionPopupWithoutTitleModel(title: "Don't_delete".localized)
        let data = [tempData1, tempData2]
        let title = "delete_expense?".localized
        self.switchOption(optionData: data, title: title, description: "this_action_cannot_be_undone.".localized) { str in
            if str == "delete".localized {
                self.simpleApprovalVM.expenseApproval.remove(at: row)
                self.simpleApprovalVM.requestExpense.remove(at: row - 3) //Seanghay > 3 ITEM ABOVE  <
                //                    self.simpleApprovalVM.selectExpenseCount = "\(self.simpleApprovalVM.requestExpense.count)"
                self.calculateTotalAmount(data: self.simpleApprovalVM.requestExpense)
                self.simpleApprovalVM.initDataWeCMS()
                self.tableView.reloadData()
                self.dismiss(animated: true)
            }else{
                self.dismiss(animated: true)
            }
        }
    }
    
    //MARK: - OBJC
    @objc func getDataAddManual(_ notification: Notification){
        let noti = notification.object as? [Any]
        
        if noti?[9] as! String == "E" {
            self.simpleApprovalVM.requestExpense.remove(at: selectedIndex - 3)
            self.simpleApprovalVM.requestExpense.insert(WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY: "\(noti?[3] ?? "")", TRCO_NICK_NM: "\(noti?[2] ?? "")", TRCO_CMNM: "\(noti?[4] ?? "")", TRCO_CMENM: "\(noti?[5] ?? "")", CCY_CD: "\(noti?[6] ?? "")", AMT: "\(noti?[7] ?? "")", BUSA_USAG_CD: "\(noti?[1] ?? "")", MEMO: "\(noti?[8] ?? "")", DOC_ID: "", DOC_TYPE: "", USAG_NM: "\(noti?[0] ?? "")"), at: selectedIndex - 3)
            
        }else{
            for (_, item) in self.simpleApprovalVM.requestExpense.enumerated(){
                if item.DOC_TYPE == "E" || item.DOC_TYPE == "B"{
                    self.simpleApprovalVM.requestExpense.removeAll()
                    self.requestExpense.removeAll()
                }
            }
            self.simpleApprovalVM.requestExpense.append(WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY: "\(noti?[3] ?? "")", TRCO_NICK_NM: "\(noti?[2] ?? "")", TRCO_CMNM: "\(noti?[4] ?? "")", TRCO_CMENM: "\(noti?[5] ?? "")", CCY_CD: "\(noti?[6] ?? "")", AMT: "\(noti?[7] ?? "")", BUSA_USAG_CD: "\(noti?[1] ?? "")", MEMO: "\(noti?[8] ?? "")", DOC_ID: "", DOC_TYPE: "", USAG_NM: "\(noti?[0] ?? "")"))
            //            self.simpleApprovalVM.simpleApproval.append(ApprovalContent(clientData: noti?[10] as! [Client.ContentBody]))
        }
        self.simpleApprovalVM.initDataWeCMS()
        self.calculateTotalAmount(data: self.simpleApprovalVM.requestExpense)
        self.tableView.reloadData()
    }
    
    @objc func getClientData(_ notification: Notification){
        let noti = notification.object
        self.clientData = noti as! [Client.ContentBody]
    }
    
    @objc func switchChanged(itemSwitch: UISwitch) { //Seanghay > CHANGE POST_STTS by SWITCH <
        let switchOn = itemSwitch.isOn
        self.POST_STTS = switchOn ? "PL" : "PV"
    }
    
    @objc func switchChangeMark(itemSwitch: UISwitch) { //Seanghay > CHANGE PIN_POST_TYPE by SWITCH <
        let switchOn = itemSwitch.isOn
        self.PIN_POST_TYPE = switchOn ? "UD" : ""  // => if on toggle = "UD" & off toggle = ""
        self.tableView.reloadData()
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            print(keyboardHeight)
            keybaordHeight = keyboardHeight //heremen // 130 : height of view top of keybaord, 86 : height of accept/reject view //
            self.mentionTableViewBottomConstraint.constant = keybaordHeight
        }
    }
}

//MARK: - SelectPurposeDelegate
extension RequestApprovalVC: SelectPurposeDelegate {
    
    func sendProjectREC(rec: LIST_POP_UP_RESPONSE.PROJECT_SITE_LIST) {
        self.simpleApprovalVM.requestExpense[selectedIndex - 3].BUSA_USAG_CD = rec.PRJT_NO
        self.simpleApprovalVM.requestExpense[selectedIndex - 3].USAG_NM = rec.PRJT_NM
        
        self.simpleApprovalVM.initDataWeCMS()
        self.tableView.reloadData()
    }
    
    // PURPOSE
    func sendRECItem(rec: LIST_POP_UP_RESPONSE.REC , type: POPUP_TYPE) {
        //Note: selectedIndex - 3 => get specific row
        self.simpleApprovalVM.requestExpense[selectedIndex - 3].BUSA_USAG_CD = rec.USE_USAG_CD
        self.simpleApprovalVM.requestExpense[selectedIndex - 3].USAG_NM = rec.USAG_NM
        
        self.simpleApprovalVM.initDataWeCMS()
        self.tableView.reloadData()
    }
    
    // Advance Legder
    func sendREC2Item(rec2: LIST_POP_UP_RESPONSE.REC2) {
    }
    
    // PURPOSE
    func sendUserListItem(userList: LIST_POP_UP_RESPONSE.USE_LIST) {
        self.simpleApprovalVM.requestExpense[selectedIndex - 3].BUSA_USAG_CD = userList.USE_USAG_CD
        self.simpleApprovalVM.requestExpense[selectedIndex - 3].USAG_NM = userList.USAG_NM
        
        self.simpleApprovalVM.initDataWeCMS()
        self.tableView.reloadData()
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension RequestApprovalVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.tableView: //Main TableView
            return simpleApprovalVM.expenseApproval.count
            
        case self.mentionTableView: //Mention TableView
            return mentionMemberVM.filteredList.count
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case self.tableView: //Main TableView
            let data = self.simpleApprovalVM.expenseApproval[indexPath.row]
            switch data.ApprovalItem {
            case .CONTENT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalFormHeaderCell", for: indexPath) as! ApprovalFormHeaderCell
                cell.titleTextView.delegate         = self
                cell.descriptionTextView.delegate   = self
                cell.titleTextView.tag              = 1000
                cell.descriptionTextView.tag        = 1001
                cell.descriptionTextView.inputAccessoryView = TopBarKeyboardView
                cell.textCountBottomConstraint.constant = tableView.frame.size.height - self.Spacing
                cell.configArticle(data: data, isArticle: false, TITLE: self.POST_TITLE, DESCRIPTION: self.POST_CONT, textCount: self.textCount)
                return cell
                
            case .IMAGE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageViewWeCMSCell", for: indexPath) as! ImageViewWeCMSCell
                cell.configImage(data: data)
                cell.deleteButton.didTap {
                    self.indexImage = indexPath.row - 1 //> Seanghay <\\ -1 for ApprovalFormHeaderCell
                    for (index,item) in self.imageIntPairs.enumerated() {
                        if item.name == self.simpleApprovalVM.expenseApproval[indexPath.row].fileName {
                            self.imageIntPairs.remove(at: index)
                        }
                    }
                    self.simpleApprovalVM.expenseApproval.remove(at: indexPath.row)
                    self.simpleApprovalVM.attacmentREC.remove(at: self.indexImage)
                    self.Spacing = self.tableView.frame.size.height - self.Spacing
                    for imgUr in self.simpleApprovalVM.attacmentREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                        self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*CGFloat(cell.imageContainView.frame.height)
                    }
                    if self.simpleApprovalVM.attacmentREC.count > 0 {
                        self.Spacing = self.tableView.frame.size.height - CGFloat(self.simpleApprovalVM.attacmentREC.count*46)  //> Seanghay <\\ 46 height of Attachment
                    }else if self.simpleApprovalVM.attacmentREC.count == 0{
                        self.Spacing = self.spceAfterText
                    }
                    
                    self.tableView.reloadData()
                }
                return cell
                
            case .ATTACMENT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttactMentsWeCMSCell", for: indexPath) as! AttactMentsWeCMSCell
                
                cell.configFile(data: data)
                cell.deleteButton.didTap {
                    let indexFile = indexPath.row - 1 //> Seanghay <\\ -1 for ApprovalFormHeaderCell
                    for (index,item) in self.imageIntPairs.enumerated() {
                        if item.name == self.simpleApprovalVM.attacmentREC[indexPath.row].FILE_NM {
                            self.imageIntPairs.remove(at: index)
                        }
                    }
                    self.simpleApprovalVM.expenseApproval.remove(at: indexPath.row)
                    self.simpleApprovalVM.attacmentREC.remove(at: indexFile)
                    self.Spacing = self.tableView.frame.size.height - self.Spacing
                    for imgUr in self.simpleApprovalVM.attacmentREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                        self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*350//> Seanghay <\\ height of image
                    }
                    if self.simpleApprovalVM.attacmentREC.count > 0 {
                        self.Spacing = self.tableView.frame.size.height - CGFloat(self.simpleApprovalVM.attacmentREC.count*46)  //> Seanghay <\\ 46 height of Attachment
                    }else if self.simpleApprovalVM.attacmentREC.count == 0{
                        self.Spacing = self.spceAfterText
                    }
                    self.tableView.reloadData()
                }
                return cell
                
            case .LINE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalLineCell", for: indexPath) as! ApprovalLineCell
                return cell
                
            case .DOCUMENTNO:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalInfoCell", for: indexPath) as! ApprovalInfoCell
                cell.amountStackView.isHidden = true
                cell.configCell(data: data)
                return cell
                
            case .REQUESTOR:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentNoWeCMSCell", for: indexPath) as! DocumentNoWeCMSCell
                cell.configCell(data: data)
                return cell
                
            case .REQUESTSCHEDULED:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalDateInfoWeCMSCell", for: indexPath) as! ApprovalDateInfoWeCMSCell
                cell.configCell(data: data, PAY_DATE: self.PAY_DATE, PAY_REQ_DATE: self.PAY_REQ_DATE)
                let today = Date()
                
                cell.selectDateButton.didTap {
                    self.dropDownSelectDate(date: cell.selectDateButton.titleLabel?.text ?? "") { option in
                        cell.selectDateButton.setTitle(     option == "" ? today.toString(format: "dd MMM yyyy") : option, for: .normal)
                        self.PAY_DATE = changeFormatDate(   option == "" ? today.toString(format: "dd MMM yyyy") : option, fromFormat: "dd MMM yyyy", toFormat: "yyyyMMdd")
                    }
                }
                return cell
                
            case .TOTALAMOUNT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalInfoWeCMSCell", for: indexPath) as! ApprovalInfoWeCMSCell
                cell.configTotalCell(data: data, TOTL_AMTUSD: self.TOTL_AMTUSD, TOTL_AMTKHR: self.TOTL_AMTKHR, TOTL_AMTVND: self.TOTL_AMTVND)
                return cell
                
            case .APPROVERS:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalSelectInfoWeCMSCell", for: indexPath) as! ApprovalSelectInfoWeCMSCell
                cell.configCell(data: data, imageSet: self.requestApprovers)
                return cell
                
            case .EXPENSES:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalSelectExpenseCell", for: indexPath) as! ApprovalSelectExpenseCell
                cell.configCell(data: data)
                return cell
                
            case .EXPENSESITEM:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseItemCell", for: indexPath) as! ExpenseItemCell
                cell.configCell(data: data)
                
                cell.purposeButton.didTap {
                    self.selectTogglePurpose(row: indexPath.row)
                }
                
                cell.purposeDropButton.didTap {
                    self.selectTogglePurpose(row: indexPath.row)
                }
                
                cell.deleteButton.didTap {
                    self.deleteExpenseItem(row: indexPath.row)
                    
                }
                return cell
                
            case .SEEMORE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SeeMoreCell", for: indexPath) as! SeeMoreCell
                return cell
                
            default:
                return UITableViewCell()
            }
            
        case self.mentionTableView: //Mention TableView
            let data = mentionMemberVM.filteredList[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "MentionMemberCell", for: indexPath) as! MentionMemberCell
            cell.configCell(data: data, index: indexPath.row)
            return cell
            
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch tableView {
        case self.tableView: //Main TableView
            let footerView = UIView()
            
            // Get the total number of rows in the section
            let totalRows = tableView.numberOfRows(inSection: section)
            
            // Check if there are at least two rows in the section
            if totalRows >= 2 {
                // Get the last two cells in the section
                let lastCellIndex = totalRows - 1
                let secondLastCellIndex = totalRows - 2
                
                let lastCell = tableView.cellForRow(at: IndexPath(row: lastCellIndex, section: section))
                let secondLastCell = tableView.cellForRow(at: IndexPath(row: secondLastCellIndex, section: section))
                
                // Add the last two cells to the footer view
                if let lastCell = lastCell {
                    footerView.addSubview(lastCell)
                }
                
                if let secondLastCell = secondLastCell {
                    footerView.addSubview(secondLastCell)
                }
            }
            
            return footerView
            
        case self.mentionTableView: //Mention TableView
            let footerView = UIView()
            return footerView
            
        default:
            return nil
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case self.tableView:
            let data = self.simpleApprovalVM.expenseApproval[indexPath.row]
            switch data.ApprovalItem {
            case .TOTALAMOUNT:
                return UITableView.automaticDimension
            default:
                return UITableView.automaticDimension
            }
        default: return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        switch tableView {
            // Main TableView
        case self.tableView:
            let lastSectionIndex = tableView.numberOfSections - 1
            let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
            
            if indexPath.section == lastSectionIndex && indexPath.row == lastRowIndex {
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: cell.frame.height, right: 0)
            }
            
        case self.mentionTableView:
            break
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case self.tableView: //Main TableView
            
            IQKeyboardManager.shared.resignOnTouchOutside = false
            if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
                if !cell.descriptionTextView.isFirstResponder {
                    cell.descriptionTextView.becomeFirstResponder()
                }
            }
            
            let data = self.simpleApprovalVM.expenseApproval[indexPath.row]
            
            switch data.ApprovalItem {
            case .APPROVERS:
                self.popSelectApprovalItem(selectCount: self.simpleApprovalVM.selectApproversCount, selectData: self.requestApprovers, BLTB_CD: "", optionType: .APPROVERS) { option,data  in
                    self.requestApprovers = data
                    if tableView.dequeueReusableCell(withIdentifier: "ApprovalSelectInfoWeCMSCell") is ApprovalSelectInfoWeCMSCell {
                        self.simpleApprovalVM.selectApproversCount = option
                        self.simpleApprovalVM.initDataWeCMS()
                        self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none)
                    }
                }
                
            case .EXPENSES:
                self.popSelectApprovalItemExpenseWeCMS(selectCount: self.simpleApprovalVM.selectExpenseCount, filterDateBill: self.filterTypeBill, filterDateReceipt: self.filterTypeReceipt, selectData: self.simpleApprovalVM.requestExpense, selectType: .RECEIPT) { option, filterDateBill, filterDateReceipt, data, selectType   in
                    self.calculateTotalAmount(data: data)
                    self.selectType         = selectType
                    self.filterTypeBill     = filterDateBill
                    self.filterTypeReceipt  = filterDateReceipt
                    self.simpleApprovalVM.requestExpense = data
                    self.simpleApprovalVM.initDataWeCMS()
                    self.tableView.reloadData()
                }
                
            case .EXPENSESITEM:
                if data.DOC_TYPE == "E"{
                    let vc = UIStoryboard(name: "ReceiptDetailsSB", bundle: nil).instantiateViewController(withIdentifier: "ReceiptDetailsVC") as! ReceiptDetailsVC
                    vc.doc_id = self.simpleApprovalVM.expenseApproval[indexPath.row].DOC_ID ?? ""
                    vc.usag_nm = self.simpleApprovalVM.expenseApproval[indexPath.row].Description ?? ""
                    vc.isRequestApproval = true
                    vc.isFromExpenseApproval = true
                    
                    let nav = UINavigationController(rootViewController: vc)
                    nav.modalPresentationStyle = .custom
                    self.present(nav, animated: true)
                    
                }else if data.DOC_TYPE == ""{
                    self.selectedIndex = indexPath.row
                    self.popAddOtherManual(dataManualExpense: data, clientData: self.clientData, isEditManual: "E")
                }
                
            case .IMAGE:
                self.currentIndexImage = indexPath.row - 1 //- 1 cuz index 0 is title & desc
                self.previewImage()
                
            case .SEEMORE:
                self.expenseListPop(optionData: self.simpleApprovalVM.requestExpense, clientData: self.clientData, isCreate: true) { data in
                    self.calculateTotalAmount(data: data)
                    self.simpleApprovalVM.requestExpense = data
                    self.simpleApprovalVM.initDataWeCMS()
                    self.tableView.reloadData()
                }
                
            default:
                break
            }
            
        case self.mentionTableView: //Mention TableView
            let data = mentionMemberVM.filteredList[indexPath.row]
            if data.email.contains(".org") || data.email.contains(".cc") || data.email.contains(".net") || data.email.contains(".com") || data.email.contains(".kr") || data.email.contains(".kh") {
                
                let name = data.name.trimmingCharacters(in: .whitespaces)
                
                let userInfo = MentionMemberUIModel(name: name, email: "@[\(name)](\(data.email))", photo: data.photo, USER_IMG: data.USER_IMG)
                
                var isAlreadyExisted = false
                for obj in mentionedMembers {
                    if obj.email == userInfo.email {
                        isAlreadyExisted = true
                        break
                    }
                }
                
                if !isAlreadyExisted {
                    mentionedMembers.append(userInfo)
                    mentionedMemberNames.append(name)
                }
                
                
                // Fucking important algorithm, without this mention could not be complete
                if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ApprovalFormHeaderCell {
                    
                    let existedText =  cell.descriptionTextView.text ?? ""
                    var newText = ""
                    
                    if cursorPosition == existedText.utf16.count || existedText.utf16.count == (cursorPosition + 1)  {
                        let split = existedText.components(separatedBy: " ")
                        let old = split.dropLast()
                        let last = split.last?.removing(charactersOf: "@")
                        
                        if last == self.stringToSearch {
                            newText = "\(old.joined(separator: " ")) \(data.name) "
                        } else {
                            newText = existedText.replace(of: "@\(stringToSearch)", with: "\(data.name) ")
                        }
                    } else {
                        
                        if stringToSearch == "@" {
                            var temptText = existedText
                            
                            if cursorPosition < temptText.utf16.count {
                                temptText.remove(at: temptText.utf16.index(temptText.utf16.startIndex, offsetBy: cursorPosition))
                                temptText.insert(contentsOf: "\(data.name) ", at: temptText.utf16.index(temptText.utf16.startIndex, offsetBy: cursorPosition))
                            }
                            
                            newText = temptText
                        } else {
                            newText = existedText.replace(of: "@\(stringToSearch)", with: "\(data.name) ")
                        }
                        
                    }
                    
                    cell.descriptionTextView.text = newText
                    self.POST_CONT = newText
                    
                    
                    if mentionedMemberNames.count > 0 {
                        let originalFont =  UIFont(name: "Inter-Medium", size: 15.0)
                        setAttributeTextView(textView: cell.descriptionTextView , textsTobeAttributed: mentionedMemberNames, defaultFont: originalFont, defaultColor: .black, attributedFont: originalFont, atrributedColor: UIColor(resource: .mainTextBulletin))
                    }
                    
                    mentionTableViewHC.constant = 0
                    UIView.animate(withDuration: 0.1) {
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                self.customAlert(type: .CONFIRM_ALERT, image: "", title: "notice".localized, message: "incorrect_email_address_format".localized, redTitle: "close".localized, greyTitle: "close".localized)
            }
            
        default:
            break
        }
    }
    
}

//MARK: - UITextViewDelegate
extension RequestApprovalVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        let originalFont =  UIFont(name: "Inter-Medium", size: 15.0)
        self.setAttributeTextView(textView: textView, textsTobeAttributed: mentionedMemberNames, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
        
        if textView.text == "Title" || textView.text == "Description (max. 200 characters)" {
            textView.text = ""
            let point           = textView.convert(CGPoint.zero, to: self.tableView)
            let indexPath       = self.tableView.indexPathForRow(at: point)!
            if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
                cell.titleTextView.placeholderText = "Title"
                cell.descriptionTextView.placeholderText = "Description (max. 200 characters)"
            }
        }
        TopBarKeyboardView.setCountFile(self.simpleApprovalVM.attacmentREC.count)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.tag == 1001 {
            IQKeyboardManager.shared.resignOnTouchOutside = true
            mentionTableViewHC.constant = 0
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        //make textview size automatic
        UIView.setAnimationsEnabled(false)
        textView.sizeToFit()
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
        let point           = textView.convert(CGPoint.zero, to: self.tableView)
        let indexPath       = self.tableView.indexPathForRow(at: point)!
        if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
            self.POST_TITLE = cell.titleTextView.text ?? ""
            self.POST_CONT  = cell.descriptionTextView.text ?? ""
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let point           = textView.convert(CGPoint.zero, to: self.tableView)
        let indexPath       = self.tableView.indexPathForRow(at: point)!
        let currentText = textView.text as NSString
        let newText = currentText.replacingCharacters(in: range, with: text)
        let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell
        if textView == cell?.titleTextView {
            let height = cell?.titleTextView.heightConstraint?.constant ?? 0
            if height < self.heightTitle {
                self.heightTitle = height
                self.Spacing = Spacing - 50 // spacing for Title
                self.spceAfterText = self.Spacing
                cell?.textCountBottomConstraint.constant = cell?.textCountBottomConstraint.constant ?? 0 <= 20 ? 20 : tableView.frame.size.height - self.Spacing
            }
            if text == "\n"{
                self.Spacing = Spacing + 40 // spacing for Title
                self.spceAfterText = self.Spacing
                cell?.textCountBottomConstraint.constant = cell?.textCountBottomConstraint.constant ?? 0 <= 20 ? 20 : tableView.frame.size.height - self.Spacing
                
            }
            self.heightTitle = height
        }else if textView == cell?.descriptionTextView {
            let height = cell?.descriptionTextView.heightConstraint?.constant ?? 0
            if height < self.heightContent {
                self.Spacing = Spacing - 18 // spacing for Title
                self.spceAfterText = self.Spacing
                cell?.textCountBottomConstraint.constant = cell?.textCountBottomConstraint.constant ?? 0 <= 20 ? 20 : tableView.frame.size.height - self.Spacing
            }
            if text == "\n"{
                self.Spacing = Spacing + 18 // spacing for Description
                self.spceAfterText = self.Spacing
                cell?.textCountBottomConstraint.constant = cell?.textCountBottomConstraint.constant ?? 0 <= 20 ? 20 : tableView.frame.size.height - self.Spacing
            }
            self.heightContent = height
        }else{
            // Do something
        }
        
        
        // ============================================== Start Mention Part ==============================================
        if textView.tag == 1001 {
            
            if textView.text.utf16.count < 2 {
                mentionedMembers = []
                mentionedMemberNames = []
            }
            
            // Navy: Mention Part
            // Typing text for search in mention
            var typingWord = ""
            
            // new updated text
            let nsString = textView.text as NSString?
            let updatedString = nsString?.replacingCharacters(in: range, with: text)
            
            // Get location of cursor
            if let selectedRange = textView.selectedTextRange {
                cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            }
            
            // ================== Fucking important note !!!!!!! =====================
            // CASE A : Incase user alway typing forward and the cursor is always at last, we easy to get tying text to search by splitting it with space
            // CASE B : Incase toxic user move cursor to the middel of middle of text, we need to get typing in few fucking steps:
            // Step 1: get location of cursor
            // Step 2: get text behind cursor by loop backward from cursor location till space then stop, then collection character one by one and make it as string
            // Step 3: The string was combinded behind the cursor are new typing text
            
            if cursorPosition == textView.text.utf16.count {
                
                let newString = updatedString ?? ""
                if newString.contains("\n")  {
                    let split = updatedString?.components(separatedBy: "\n")
                    let lastSplit = split?.last
                    
                    
                    let split2 = lastSplit?.components(separatedBy: " ")
                    typingWord = split2?.last ?? ""
                    
                    
                } else {
                    let split = updatedString?.components(separatedBy: " ")
                    typingWord = split?.last ?? ""
                }
                
                
                if mentionedMemberNames.count > 0 {
                    let originalFont =  UIFont(name: "Inter-Medium", size: 15.0)
                    self.setAttributeTextView(textView: textView, textsTobeAttributed: mentionedMemberNames, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
                }
                
            } else {
                
                var newStringArray = [""]
                
                for index in (0...cursorPosition).reversed() {
                    
                    let str = "\(updatedString ?? "")"
                    let stringArray = Array(str)
                    
                    // check prevent crash when user hold backspace button
                    if text != "" {
                        if stringArray.count > index {
                            if stringArray[index] == " " || stringArray[index] == "\n" {
                                break
                            } else {
                                newStringArray.insert(String(stringArray[index]), at: 0)
                            }
                        }
                    }
                }
                
                typingWord = newStringArray.joined(separator: "")
                
                if typingWord.contains("\n") {
                    typingWord = typingWord.removing(charactersOf: "\n")
                }
                
            }
            
            
            
            let numberOfAddress = typingWord.numberOfOccurrencesOf(string: "@")
            if  numberOfAddress == 1 {
                
                if typingWord == "@" /*|| typingWord.last == "@"*/ {
                    stringToSearch = ""
                } else if typingWord.first == ("@") || typingWord.getLast2Characters() == "\n@" {
                    stringToSearch = typingWord.removing(charactersOf: "@").replace(of: "\n", with: "")
                } else {
                    mentionMemberVM.filteredList = []
                }
                let BLTB_CD  =  Shared.BLTB_CD  == "" ? "999999999999999" : Shared.BLTB_CD
                let body =  WABOOKS_MREC_BLTB_0004_R001.REQUEST(BLTB_CD: BLTB_CD, USER_NM: stringToSearch.removing(charactersOf: "@"))
                self.mentionMemberVM.requestMentionMembers(body: body) { result in
                    switch result {
                    case .success(_):
                        
                        self.mentionTableView.reloadData()
                        
                        // Show or Hide tableView
                        if self.mentionMemberVM.filteredList.count != 0 {
                            _ = self.screenHeight / 3
                            self.mentionTableViewHC.constant = 230
                            IQKeyboardManager.shared.resignOnTouchOutside = false
                            
                        } else {
                            IQKeyboardManager.shared.resignOnTouchOutside = true
                            self.mentionTableViewHC.constant = 0
                        }
                        
                        
                    case .failure(let error):
                        print(error)
                    }
                }
                
                
            } else {
                IQKeyboardManager.shared.resignOnTouchOutside = true
                mentionTableViewHC.constant = 0
            }
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            // ============================================== End Mention Part ==============================================
            
        }
        if textView == cell?.descriptionTextView {
            textCount = newText.count
            if textCount <= 200 {
                cell?.textCountLabel.text        = "\(textCount)/200"
                cell?.textCountLabel.textColor   = .gray
            }
        }
        
        return textView == cell?.descriptionTextView ? newText.count <= 200 : true
    }
}

//MARK: - TopBarKeyboardDelegate
extension RequestApprovalVC: TopBarKeyboardDelegate {
    func addFile(_ files: [FileModel]) {
        for file in files {
            self.simpleApprovalVM.attacmentREC.append(WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC3(FILE_NM: file.fileName, FILE_DATA: "\(file.fileData)"))
            self.Spacing = self.Spacing + CGFloat(self.simpleApprovalVM.attacmentArticleREC.count*46)
            if self.simpleApprovalVM.attacmentREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}).count > 0 {
                self.Spacing = self.tableView.frame.size.height - 20
            }
            TopBarKeyboardView.setCountFile(self.simpleApprovalVM.attacmentREC.count)
        }
        self.simpleApprovalVM.initDataWeCMS()
        self.tableView.reloadData()
    }
    
    func addImage(_ images: [UIImage]) {
        if images.count != 0 {
            for (i, image) in images.enumerated() {
                if let base64 = convertToBase64(image) {
                    let formatter           = DateFormatter()
                    formatter.dateFormat    = "yyyMMddHHmm"
                    
                    self.simpleApprovalVM.attacmentREC.append(WABOOKS_MREC_BLTB_0004_C002.REQUEST.REC3(FILE_NM: "\(formatter.string(from: Date()))\(i).jpg", FILE_DATA: base64))
                    self.imageIntPairs.append(ImageFullSize(image: image, name: "\(formatter.string(from: Date()))\(i).jpg"))
                    TopBarKeyboardView.setCountFile(self.simpleApprovalVM.attacmentREC.count)
                    
                }
            }
        }
        self.Spacing = self.tableView.frame.size.height - 20
        
        self.simpleApprovalVM.initDataWeCMS()
        self.tableView.reloadData()
    }
    
    func dismissKeyboard() {
        let point     = tableView.convert(CGPoint.zero, to: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: point)!
        if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
            cell.descriptionTextView.resignFirstResponder()
        }
    }
    
}

