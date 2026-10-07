//
//  EditDraftWeCMSVC.swift
//  WeCMS_iOS
//
//  Created by lymanny on 16/1/25.
//
//  Note: This class was adapted from EditDraftVC
//  Some conditions and methods have been modified to fit the requirements of the EditDraftWeCMS feature.

import UIKit
import IQKeyboardManagerSwift
import SDWebImage

class EditDraftWeCMSVC: UIViewController {
    
    //MARK: - @IBOutlet
    //> Seanghay <\\ NAVIGATION
    @IBOutlet weak var navigatBackView    : UIView!
    @IBOutlet weak var backButton         : UIButton!
    @IBOutlet weak var navigatTitleLabel  : UILabel!
    
    //> Seanghay <\\ TABLE VIEW
    @IBOutlet weak var tableView          : UITableView!
    @IBOutlet weak var mentionTableView   : UITableView!
    @IBOutlet weak var mentionTableViewHC : NSLayoutConstraint!
    
    //> Seanghay <\\ REQUEST BUTTON
    @IBOutlet weak var requestBackView    : UIView!
    @IBOutlet weak var requestButton      : UIButton!
    
    //MARK: - Properties & Variable
    var approvalType: DraftApprovalType  = .NEWARTICLE
    var approvalPop: DraftApprovalType   = .NEWARTICLE
    var textViewType: TextViewType       = .TITLE
    var editDraftVM                      = EditDraftVM()
    var simpleApprovalVM                 = SimpleApprovalVM()
    var selectExpensesVM                 = SelectExpensesVM()
    var selectType: SelectedExpenseType  = .RECEIPT
    
    var requestApprovers     : [MREC_BLTB_0004_C002.REQUEST.REC6] = []
    var requestExpense       : [MREC_BLTB_0004_C002.REQUEST.REC1] = []
    var deleteFILEREC        : [MREC_BLTB_0004_C002.REQUEST.REC5] = []
    var deleteFileArticleREC : [MREC_BLTB_0004_C001.REQUEST.REC3] = []
    
    var indexImage = 0
    var setFile: [FileModel] = []
    
    var selectExpenseCount   = ""
    var filterType : RowType = .LastOneMonth
    
    var PAY_REQ_DATE    = ""
    var PAY_DATE        = ""
    var POST_TITLE      = ""
    var POST_CONT       = ""
    var POST_CONT_Formatted   = ""
    var POST_STTS             = "PL"
    var PIN_POST_TYPE         = ""
    var PIN_POST_DUE_DT       = "forever".localized
    var selectDateType        = "save_permanently".localized
    var TOTL_AMTKHR:Double    = 0
    var TOTL_AMTUSD:Double    = 0
    var TOTL_AMTVND:Double    = 0
    var DRAFT_POST_SEQ_NO     = ""
    var BLTB_CD               = ""
    var POST_TYPE_CD          = ""
    var Spacing:CGFloat       = 300 // spacing between Content and Item
    var spceAfterText:CGFloat = 300
    var boardRec              : [MREC_BLTB_0001_R001.RESPONSE.REC] = []
    var isFirstLoaded         = true
    
    var heightTitle: CGFloat    = 0
    var heightContent: CGFloat  = 0
    
    // max image : for choosing from gallery
    private var selectedImages   : UIImage? //image choosen from Gallary
    var currentIndexImage        : Int? = 0
    var selectedContactIndexPath : IndexPath?
    var receiptImage             : UIImageView?      // For Zoom animation
    
    let mentionMemberVM          = MentionMemberVM()
    var cursorPosition           = 0
    var stringToSearch           = ""
    var mentionedMemberNames     : [String] = []
    var mentionedMembers         : [MentionMemberUIModel] = []

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
        TopBarKeyboardView.delegate = self
        mentionTableViewHC.constant = 0
        self.mentionMemberVM.initCellData(data: [])
        self.registerCell()
        self.fetchDraft()
        self.mentionTableView.register(UINib(nibName: "MentionMemberCell", bundle: nil), forCellReuseIdentifier: "MentionMemberCell")
        self.navigatTitleLabel.getlocalizedFont()
        self.requestButton.getlocalizedFont()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case NotifyKey.gotoPhotoPreviewVC.rawValue :
            let vc = segue.destination as! PhotoPreviewsVC
            var imgRec : [Any] = []
            for item in self.editDraftVM.imageIntPairs {
                imgRec.append(item.image ?? UIImage())
            }
            vc.imageUrlArray      = [["RCPT_IMG_URL" : imgRec]] as Array<AnyObject>
            vc.currentIndexImage  = currentIndexImage
            vc.isBtnDeleteDisable = true
        default: break
             
        }
    }
    
    //MARK: - @IBAction
    @IBAction func didTapBackAction(_ sender: Any) {
        self.POST_CONT_Formatted = mentionedMembers.count == 0 ? self.POST_CONT : self.formatMentionFromReadableToAPISyntax(originalText: POST_CONT, mentionedMembers: mentionedMembers)
        if self.POST_TITLE.isEmpty && self.POST_CONT.isEmpty {
            self.dismiss(animated: true)
        }else {
            let tempData1 = OptionPopupWithoutTitleModel(title: "save_draft".localized)
            let tempData2 = OptionPopupWithoutTitleModel(title: "keep_writing".localized)
            let tempData3 = OptionPopupWithoutTitleModel(title: "discard".localized)
            let data = [tempData1, tempData2, tempData3]
            self.switchOption(optionData: data, title: "save_as_draft?".localized, description: "draft_lets_you_edit_your_post_later_or_tap_discard_to_cancel_posting.".localized) { str in
                if str == "save_draft".localized {
                    switch self.approvalType {
                    case .SIMPLEAPPROVAl:
                        self.createApproval(saveDraft: "Y")
                    case .EXPENSEAPPROVAL:
                        self.createExpense(saveDraft: "Y")
                    case .NEWARTICLE:
                        self.createNewArticle(saveDraft: "Y")
                    }
                    self.dismiss(animated: true)
                }
                else if str == "discard".localized {
                    self.dismiss(animated: true)
                    self.dismiss(animated: true)
                }
                else{
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    @IBAction func didSelectApprovalAction(_ sender: Any) {
        let tempData1 = OptionPopupWithoutTitleModel(icon: "check_text_box",   title: "Edit_Simple_Approval".localized)
        let tempData2 = OptionPopupWithoutTitleModel(icon: "approval_icon",    title: "Edit Request Approval")
        let tempData3 = OptionPopupWithoutTitleModel(icon: "ico_article",      title: "Edit_Article".localized)
        let data = self.editDraftVM.responseDraft?.POST_TYPE_CD != "02" ? [tempData3, tempData1, tempData2] : [tempData1, tempData2]
        self.selectOptionWithChek(optionData: data, defaultApproval: self.navigatTitleLabel.text ?? "Edit Request Approval", isNewArticle: approvalPop == .NEWARTICLE ? true : false, isDraft: true){ value in
            self.dismiss(animated: true)
            let tempData1 = OptionPopupWithoutTitleModel(title: "switch_now".localized)
            let tempData2 = OptionPopupWithoutTitleModel(title: "keep_writing".localized)
            let data = [tempData1, tempData2]
            var title = ""
            switch value {
            case "Edit_Simple_Approval".localized:
                title = "switch_to_simple_approval?".localized
                if self.POST_CONT.isEmpty && self.POST_TITLE.isEmpty {
                    self.navigatTitleLabel.text = value
                    self.approvalType = .SIMPLEAPPROVAl
                    self.requestButton.setTitle("request".localized, for: .normal)
                    self.Spacing = self.editDraftVM.attacmentREC.count > 0 ? self.tableView.frame.size.height - 20 : 300
                    self.POST_TYPE_CD = "02"
                    self.tableView.reloadData()
                }else{
                    self.switchOption(optionData: data, title: title, description: "your_current_writings_will_be_unsaved.".localized) { str in
                        if str == "switch_now".localized {
                            self.navigatTitleLabel.text = value
                            self.approvalType = .SIMPLEAPPROVAl
                            self.requestButton.setTitle("request".localized, for: .normal)
                            self.Spacing = self.editDraftVM.attacmentREC.count > 0 ? self.tableView.frame.size.height - 20 : 300
                            self.POST_TYPE_CD = "02"
                            self.tableView.reloadData()
                            self.dismiss(animated: true)
                        }else{
                            self.dismiss(animated: true)
                        }
                        
                    }
                }
            case "Edit Request Approval":
                title = "switch_to_expenses_approval?".localized
                if self.POST_CONT.isEmpty && self.POST_TITLE.isEmpty {
                    self.navigatTitleLabel.text = value
                    self.approvalType = .EXPENSEAPPROVAL
                    self.requestButton.setTitle("request".localized, for: .normal)
                    self.Spacing = self.editDraftVM.attacmentREC.count > 0 ? self.tableView.frame.size.height - 20 : 460
                    self.POST_TYPE_CD = "02"
                    self.tableView.reloadData()
                }else{
                    self.switchOption(optionData: data, title: title, description: "your_current_writings_will_be_unsaved.".localized) { str in
                        if str == "switch_now".localized {
                            self.navigatTitleLabel.text = value
                            self.approvalType = .EXPENSEAPPROVAL
                            self.requestButton.setTitle("request".localized, for: .normal)
                            self.Spacing = self.editDraftVM.attacmentREC.count > 0 ? self.tableView.frame.size.height - 20 : 460
                            self.POST_TYPE_CD = "02"
                            self.tableView.reloadData()
                            self.dismiss(animated: true)
                        }else{
                            self.dismiss(animated: true)
                        }
                    }
                }
            case "Edit_Article".localized:
                self.approvalType = .NEWARTICLE
                self.requestButton.setTitle("post".localized, for: .normal)
                self.Spacing = self.editDraftVM.attacmentArticleREC.count > 0 ? self.tableView.frame.size.height - 20 : 300
                self.POST_TYPE_CD = "01"
                self.tableView.reloadData()
            default:
                self.approvalType = .EXPENSEAPPROVAL
                self.Spacing = 300
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func didTapRequestButton(_ sender: Any) {
        // *** NOTE ***
        // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
        // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
        self.POST_CONT_Formatted = mentionedMembers.count == 0 ? self.POST_CONT : self.formatMentionFromReadableToAPISyntax(originalText: POST_CONT, mentionedMembers: mentionedMembers)
//        if mentionedMembers.count == 0 {
//            POST_CONT_Formatted = POST_CONT
//        } else {
//            POST_CONT_Formatted = self.formatMentionFromReadableToAPISyntax(originalText: POST_CONT, mentionedMembers: mentionedMembers)
//        }
        
        switch approvalType {
        case .SIMPLEAPPROVAl:
            self.createApproval()
        case .EXPENSEAPPROVAL:
            self.createExpense()
        case .NEWARTICLE:
            self.createNewArticle()
        }
    }
    
    //MARK: - Function
    func previewImage() {
        self.performSegue(withIdentifier: NotifyKey.gotoPhotoPreviewVC.rawValue, sender: nil)
    }
    
    func fetchDraft() {
        self.editDraftVM.fetchEditDraftWeCMS(DRAFT_POST_SEQ_NO: self.DRAFT_POST_SEQ_NO, BLTB_CD: self.BLTB_CD, POST_TYPE_CD: self.POST_TYPE_CD) { result in
            switch result {
            case .success(let data):
                print(data)
                self.PAY_DATE       = data.PAY_DATE ?? ""
                self.PAY_REQ_DATE   = data.PAY_REQ_DATE ?? ""
                self.POST_TITLE     = data.POST_TITLE ?? ""
                self.POST_CONT      = data.POST_CONT ?? ""
                self.POST_STTS      = data.POST_STTS ?? ""
                self.PIN_POST_TYPE  = data.DRAFT_PIN_POST_TYPE ?? ""
                self.PIN_POST_DUE_DT = data.DRAFT_PIN_POST_DUE_DT ?? ""
                
                self.setUpView()
                self.tableView.reloadData()
            case .failure(let error):
                self.alertError(message: error.localizedDescription )
            }
        }
    }
    
    private func createApproval(saveDraft: String = "N") {
        let REC1 = self.requestExpense
        let REC3 = self.editDraftVM.attacmentREC
        let REC6 = self.requestApprovers
        let REC5 = self.deleteFILEREC
        // *** NOTE ***
        // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
        // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
        
//        if mentionedMembers.count == 0 {
//            POST_CONT_Formatted = POST_CONT
//        } else {
//            POST_CONT_Formatted = self.formatMentionFromReadableToAPISyntax(originalText: POST_CONT, mentionedMembers: mentionedMembers)
//        }
        
        self.simpleApprovalVM.createApproval(body: MREC_BLTB_0004_C002.REQUEST(APPR_DV          : "70",
                                                                                       PAY_DATE         : self.PAY_DATE,
                                                                                       TOT_PAY_LOC_AMT  : 0,
                                                                                       TOT_PAY_USD_AMT  : 0,
                                                                                       SAL_REG_SEQ_NO   : "",
                                                                                       PAYM_AMT_BYDF    : "",
                                                                                       PAY_REQ_DATE     : self.PAY_REQ_DATE,
                                                                                       REF_DATA_CNT     : nil,//"Added (2022/04/26)resl_0002_001_r001 >> TOT_CNT 값 Bypass. Table No. 1 Insert"
                                                                                       APLY_EXCH_RATE   : 4081,//"V2023.1.0.29 Table 1, APPR_DV = '00' : Required(Now It use only in VN version)"
                                                                                       DRAFT_POST_SEQ_NO: self.editDraftVM.responseDraft?.DRAFT_POST_SEQ_NO ?? "",//It required when Open as draft
                                                                                       POST_TITLE       : self.POST_TITLE,
                                                                                       POST_APPR_DV     : "00",// "Table 9, 12", '00': Simple Approval, '10': Expense Approval"
                                                                                       POST_CONT        : self.POST_CONT_Formatted.convertStringToHTML,
                                                                                       POST_DRAFT_YN    : saveDraft, //Y: Save draft, N: Post or Request
                                                                                       REC1             : REC1,
                                                                                       REC2             : [],
                                                                                       REC5             : REC5,
                                                                                       REC6             : REC6,
                                                                                       REC3             : REC3
                                                                                      )) { error in
            if error != nil {
                self.alertError(message: error?.localizedDescription ?? "Error")
            }else{
                if saveDraft == "Y" {
                    let leftTitle = "Saved to draft!"
                    let message = "You can find draft post in the board -> Draft"
                    self.infoMessagePopup(iconName: "ico_check-2", title: leftTitle, message: message, confirmTitle: "Okay") { isOkay in
                        print("okay")
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
    
    private func createExpense(saveDraft: String = "N") {
        let REC1 = self.requestExpense
        let REC3 = self.editDraftVM.attacmentREC
        let REC6 = self.requestApprovers
        let REC5 = self.deleteFILEREC
        let TOT_LOC = self.TOTL_AMTVND
        // *** NOTE ***
        // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
        // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
        
//        if mentionedMembers.count == 0 {
//            POST_CONT_Formatted = POST_CONT
//        } else {
//            POST_CONT_Formatted = self.formatMentionFromReadableToAPISyntax(originalText: POST_CONT, mentionedMembers: mentionedMembers)
//        }
        
        self.simpleApprovalVM.createApproval(body: MREC_BLTB_0004_C002.REQUEST(APPR_DV          : "00",
                                                                                       PAY_DATE         : self.PAY_DATE,
                                                                                       TOT_PAY_LOC_AMT  : Int(TOT_LOC),
                                                                                       TOT_PAY_USD_AMT  : Int(self.TOTL_AMTUSD),
                                                                                       SAL_REG_SEQ_NO   : "",
                                                                                       PAYM_AMT_BYDF    : "",
                                                                                       PAY_REQ_DATE     : self.PAY_REQ_DATE,
                                                                                       REF_DATA_CNT     : "",//"Added (2022/04/26)resl_0002_001_r001 >> TOT_CNT 값 Bypass. Table No. 1 Insert"
                                                                                       APLY_EXCH_RATE   : 4081,//"V2023.1.0.29 Table 1, APPR_DV = '00' : Required(Now It use only in VN version)"
                                                                                       DRAFT_POST_SEQ_NO: self.editDraftVM.responseDraft?.DRAFT_POST_SEQ_NO ?? "",//It required when Open as draft
                                                                                       POST_TITLE       : self.POST_TITLE,
                                                                                       POST_APPR_DV     : "10",// "Table 9, 12", '00': Simple Approval, '10': Expense Approval"
                                                                                       POST_CONT        : self.POST_CONT_Formatted.convertStringToHTML,
                                                                                       POST_DRAFT_YN    : saveDraft, //Y: Save draft, N: Post or Request
                                                                                       REC1             : REC1,
                                                                                       REC2             : [],
                                                                                       REC5             : REC5,
                                                                                       REC6             : REC6,
                                                                                       REC3             : REC3
                                                                                      )) { error in
            if error != nil {
                self.alertError(message: error?.localizedDescription ?? "Error")
            }else{
                if saveDraft == "Y" {
                    let leftTitle = "Saved to draft!"
                    let message = "You can find draft post in the board -> Draft"
                    self.infoMessagePopup(iconName: "ico_check-2", title: leftTitle, message: message, confirmTitle: "Okay") { isOkay in
                        print("okay")
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
    
    private func createNewArticle(saveDraft: String = "N") {
        let REC = self.editDraftVM.attacmentArticleREC
        var REC2 : [MREC_BLTB_0004_C001.REQUEST.REC2] = []
        let REC3 = self.deleteFileArticleREC
        // *** NOTE ***
        // 👉 no need to formatted POST_CONT into user info form, if no member has been mentioned
        // 👉 when one or more member has been mentioned in the POST_CONT, must format it into user info form => "@[Sokny Ran (Yakuza)](soknyran.dev@gmail.com)"
        
//        if mentionedMembers.count == 0 {
//            POST_CONT_Formatted = POST_CONT
//        } else {
//            POST_CONT_Formatted = self.formatMentionFromReadableToAPISyntax(originalText: POST_CONT, mentionedMembers: mentionedMembers)
//        }
        
//        if Shared.boardType == .Home || Shared.boardType == .MyPosts{   //For case Home & Myposts boards default key BLTB_CD = 999999999999999
//            REC2 = [MREC_BLTB_0004_C001.REQUEST.REC2(BLTB_CD: "999999999999999")]
//
//        }else{   //For case Favorite & General get a key BLTB_CD from api MREC_BLTB_0001_R001 when select specific board
            REC2 = [MREC_BLTB_0004_C001.REQUEST.REC2(BLTB_CD: self.editDraftVM.responseDraft?.BLTB_CD)]
//        }
        if self.PIN_POST_DUE_DT.contains("-"){
            self.PIN_POST_DUE_DT = changeFormatDate(self.PIN_POST_DUE_DT, fromFormat: "dd-MM-yyyy", toFormat: "yyyyMMdd")
        }
        
        self.simpleApprovalVM.createNewArticle(body: MREC_BLTB_0004_C001.REQUEST(DRAFT_POST_SEQ_NO  : self.editDraftVM.responseDraft?.DRAFT_POST_SEQ_NO ?? "",
                                                                                         POST_TITLE         : self.POST_TITLE,
                                                                                         POST_ANTH_BLTB_YN  : "N",
                                                                                         POST_TYPE_CD       : self.POST_TYPE_CD,
                                                                                         POST_CONT          : self.POST_CONT_Formatted.convertStringToHTML,
                                                                                         POST_STTS          : self.POST_STTS,
                                                                                         POST_DRAFT_YN      : saveDraft,
                                                                                         PIN_POST_TYPE      : self.PIN_POST_TYPE == "" ? nil : self.PIN_POST_TYPE,
                                                                                         PIN_POST_DUE_DT    : self.PIN_POST_DUE_DT == "permanently".localized ? "" : self.PIN_POST_DUE_DT,
                                                                                         REF_BLTB_CD        : "",
                                                                                         REF_POST_SEQ_NO    : "",
                                                                                         REC3               : REC3,
                                                                                         REC2               : REC2,
                                                                                         REC                : REC)) { error in
            if error != nil {
                self.alertError(message: error?.localizedDescription ?? "Error")
            }else{
                if saveDraft == "Y" {
                    let leftTitle = "Saved to draft!"
                    let message = "You can find draft post in the board -> Draft"
                    self.infoMessagePopup(iconName: "ico_check-2", title: leftTitle, message: message, confirmTitle: "Okay") { isOkay in
                        print("okay")
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
    
    private func calculateTotalAmount(data:  [MREC_BLTB_0004_C002.REQUEST.REC1]) {
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
    
    private func registerCell() {
        self.tableView.register(UINib(nibName: "ApprovalFormHeaderCell", bundle: nil), forCellReuseIdentifier: "ApprovalFormHeaderCell")
        self.tableView.register(UINib(nibName: "ApprovalInfoWeCMSCell", bundle: nil), forCellReuseIdentifier: "ApprovalInfoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalDateInfoCell", bundle: nil), forCellReuseIdentifier: "ApprovalDateInfoCell")
        self.tableView.register(UINib(nibName: "ApprovalDateInfoWeCMSCell", bundle: nil), forCellReuseIdentifier: "ApprovalDateInfoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalSelectInfoWeCMSCell", bundle: nil), forCellReuseIdentifier: "ApprovalSelectInfoWeCMSCell")
        self.tableView.register(UINib(nibName: "ApprovalLineCell", bundle: nil), forCellReuseIdentifier: "ApprovalLineCell")
        self.tableView.register(UINib(nibName: "ImageViewWeCMSCell", bundle: nil), forCellReuseIdentifier: "ImageViewWeCMSCell")
        self.tableView.register(UINib(nibName: "AttactMentsWeCMSCell", bundle: nil), forCellReuseIdentifier: "AttactMentsWeCMSCell")
        self.tableView.register(UINib(nibName: "ArticleToggleCell", bundle: nil), forCellReuseIdentifier: "ArticleToggleCell")
        self.tableView.register(UINib(nibName: "ExpenseItemCell", bundle: nil), forCellReuseIdentifier: "ExpenseItemCell")
        self.tableView.register(UINib(nibName: "SeeMoreCell", bundle: nil), forCellReuseIdentifier: "SeeMoreCell")
        self.tableView.register(UINib(nibName: "ApprovalSelectExpenseCell", bundle: nil), forCellReuseIdentifier: "ApprovalSelectExpenseCell")
        self.tableView.register(UINib(nibName: "DocumentNoCell", bundle: nil), forCellReuseIdentifier: "DocumentNoCell")
        self.tableView.register(UINib(nibName: "DocumentNoWeCMSCell", bundle: nil), forCellReuseIdentifier: "DocumentNoWeCMSCell")
        
    }
    
    func getExistedMentionedMember(content: String) {
        let formatedComponent   = self.formatMentionFromAPISyntaxToReadable(originalText: content)
        let mentionedMemberFullInfo = formatedComponent.2
        for obj in mentionedMemberFullInfo {
            let split = obj.components(separatedBy: "](")
            
            if split.count == 2 {
                let name = split.first?.replace(of: "@[", with: "") ?? ""
                //                let email = split.last?.replace(of: ")", with: "") ?? ""
                let user = MentionMemberUIModel(name: name, email: obj, photo: "", USER_IMG: "")
                mentionedMemberNames.append(name)
                mentionedMembers.append(user)
            }
        }
    }
    
    private func setUpView() {
        self.requestButton.isUserInteractionEnabled = true
        if self.editDraftVM.responseDraft?.REC3.count ?? 0 > 0 {
            for item in (self.editDraftVM.responseDraft?.REC3 ?? []) {
                self.requestApprovers.append(MREC_BLTB_0004_C002.REQUEST.REC6(APPRVR_ID: item.APPRVR_ID, APPRVR_NM: item.APPRVR_NM, APPRVR_STTS: item.APPRVR_STTS, APPRVR_IMG_URL: item.APPRVR_IMG_URL))
                self.editDraftVM.selectApproversCount = "\(self.editDraftVM.responseDraft?.REC3.count ?? 0)/4"
            }
        }
        if self.editDraftVM.responseDraft?.REC2.count ?? 0 > 0 {
            for item in (self.editDraftVM.responseDraft?.REC2 ?? []) {
                self.editDraftVM.requestExpense.append(MREC_BLTB_0004_C002.REQUEST.REC1(TRCO_KEY: item.TRCO_KEY, TRCO_CMNM: item.TRCO_CMNM, TRCO_CMENM: item.TRCO_CMENM, CCY_CD: item.CCY_CD, AMT: item.AMT, BUSA_USAG_CD: item.BUSA_USAG_CD, MEMO: item.MEMO, DOC_ID: item.DOC_ID, DOC_TYPE: item.DOC_TYPE, USAG_NM: item.USAG_NM))
                self.editDraftVM.selectExpenseCount = "\(self.editDraftVM.responseDraft?.REC2.count ?? 0)"
            }
        }
        self.TOTL_AMTUSD = Double(self.editDraftVM.responseDraft?.TOT_PAY_USD_AMT ?? "") ?? 0
        self.TOTL_AMTKHR = Double(self.editDraftVM.responseDraft?.TOT_PAY_KHR_AMT ?? "") ?? 0
        //> Seanghay <\\ for viet name version
        self.TOTL_AMTVND = Double(self.editDraftVM.responseDraft?.TOT_PAY_KHR_AMT ?? "") ?? 0

        self.editDraftVM.injectDataWeCMS()
        switch approvalType {
        case .SIMPLEAPPROVAl:
            self.navigatTitleLabel.text = "Edit_Simple_Approval".localized
            self.requestButton.setTitle("request".localized, for: .normal)
            self.Spacing = self.editDraftVM.attacmentREC.count > 0 ? self.tableView.frame.size.height - 20 : 300
        case .EXPENSEAPPROVAL:
            self.navigatTitleLabel.text = "Edit Request Approval"
            self.requestButton.setTitle("request".localized, for: .normal)
            self.Spacing = self.editDraftVM.attacmentREC.count > 0 ? self.tableView.frame.size.height - 20 : 460
        case .NEWARTICLE:
            self.navigatTitleLabel.text = "Edit_Article".localized
            self.requestButton.setTitle("post".localized, for: .normal)
            self.Spacing = self.editDraftVM.attacmentArticleREC.count > 0 ? self.tableView.frame.size.height - 20 : 300
        }
    }
    
    //MARK: - OBJC
    @objc func switchChanged(itemSwitch: UISwitch) {
        let switchOn = itemSwitch.isOn
        self.POST_STTS = switchOn ? "PL" : "PV"
    }
    
    @objc func switchChangeMark(itemSwitch: UISwitch) {
        let switchOn = itemSwitch.isOn
        self.PIN_POST_TYPE = switchOn ? "UD" : ""  // => if on toggle = "UD" & off toggle = ""
        self.tableView.reloadData()
    }
}

//MARK: - UITableViewDelegate, UITableViewDataSource
extension EditDraftWeCMSVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch tableView {
        // Main TableView
        case self.tableView:
            switch approvalType {
            case .SIMPLEAPPROVAl:
                return editDraftVM.simpleApproval.count
            case .EXPENSEAPPROVAL:
                return editDraftVM.expenseApproval.count
            case .NEWARTICLE:
                return editDraftVM.newArticleApproval.count
            }
            
        // Mention TableView
        case self.mentionTableView:
            return mentionMemberVM.filteredList.count
            
        default:
            return 0
        }
        
    
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case self.tableView:
            switch approvalType {
            case .SIMPLEAPPROVAl, .NEWARTICLE:
                return UITableView.automaticDimension
            case .EXPENSEAPPROVAL:
                let data = self.editDraftVM.expenseApproval[indexPath.row]
                switch data.ApprovalItem {
                case .TOTALAMOUNT:
                    return UITableView.automaticDimension
                default:
                    return UITableView.automaticDimension
                    
                }
            }
        case self.mentionTableView:
            return UITableView.automaticDimension
        default:
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        switch tableView {
        // Main TableView
        case self.tableView:
        switch approvalType {
        case .SIMPLEAPPROVAl:
            let data = self.editDraftVM.simpleApproval[indexPath.row]
            switch data.ApprovalItem {
            case .CONTENT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalFormHeaderCell", for: indexPath) as! ApprovalFormHeaderCell
                
                
                if isFirstLoaded {
                    getExistedMentionedMember(content: data.Description ?? "")
                }
                if isFirstLoaded {
                    isFirstLoaded = false
                }
                
                cell.titleTextView.delegate         = self
                cell.descriptionTextView.delegate   = self
                cell.titleTextView.tag              = 1000
                cell.descriptionTextView.tag        = 1001
                cell.titleTextView.textColor        = .label
//                cell.descriptionTextView.textColor  = .label
                cell.textCountLabel.textColor      = .gray
                cell.descriptionTextView.inputAccessoryView = TopBarKeyboardView
                let tableViewHeight = tableView.frame.size.height
                cell.textCountBottomConstraint.constant = tableViewHeight - self.Spacing
                cell.configDraft(data: data, isArticle: false)
                return cell
                
            case .IMAGE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageViewWeCMSCell", for: indexPath) as! ImageViewWeCMSCell
                cell.configImageDraft(data: data)
                cell.deleteButton.didTap {
                    self.indexImage = indexPath.row - 1 // for ApprovalFormHeaderCell
                    for (index,item) in self.editDraftVM.imageIntPairs.enumerated() {
                        if item.name == self.editDraftVM.simpleApproval[indexPath.row].fileName {
                            self.editDraftVM.imageIntPairs.remove(at: index)
                        }
                    }
                    if self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentREC[self.indexImage].FILE_NM}).count > 0 {
                        let fileID = self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentREC[self.indexImage].FILE_NM}).first?.FILE_ID
                        self.deleteFILEREC.append(MREC_BLTB_0004_C002.REQUEST.REC5(FILE_ID: fileID))
                    }
                    self.editDraftVM.simpleApproval.remove(at: indexPath.row)
                    self.editDraftVM.attacmentREC.remove(at: self.indexImage)
                    self.Spacing = self.tableView.frame.size.height - self.Spacing
                    for imgUr in self.editDraftVM.attacmentREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                        self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*CGFloat(cell.imageContainView.frame.height)
                    }
                    if self.editDraftVM.attacmentREC.count > 0 {
                        self.Spacing = self.tableView.frame.size.height - CGFloat(self.editDraftVM.attacmentREC.count*46) //> Seanghay <\\ 46 height of Attachment
                    }else if self.editDraftVM.attacmentREC.count == 0{
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
                    if self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentREC[self.indexImage].FILE_NM}).count > 0 {
                        let fileID = self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentREC[self.indexImage].FILE_NM}).first?.FILE_ID
                        self.deleteFILEREC.append(MREC_BLTB_0004_C002.REQUEST.REC5(FILE_ID: fileID))
                    }
                    self.editDraftVM.simpleApproval.remove(at: indexPath.row)
                    self.editDraftVM.attacmentREC.remove(at: indexFile)
                    self.Spacing = self.tableView.frame.size.height - self.Spacing
                    for imgUr in self.editDraftVM.attacmentREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                        self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*350 //> Seanghay <\\ height of image
                    }
                    if self.editDraftVM.attacmentREC.count > 0 {
                        self.Spacing = self.tableView.frame.size.height - CGFloat(self.editDraftVM.attacmentREC.count*46) //> Seanghay <\\ 46 height of Attachment
                    }else if self.editDraftVM.attacmentREC.count == 0{
                        self.Spacing = self.spceAfterText
                    }
                    self.tableView.reloadData()
                }
                return cell
                
            case .LINE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalLineCell", for: indexPath) as! ApprovalLineCell
                return cell
                
            case .REQUESTOR:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentNoCell", for: indexPath) as! DocumentNoCell
//                cell.amountStackView.isHidden = true
                cell.configCell(data: data)
                return cell
            case .APPROVERS:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalSelectInfoWeCMSCell", for: indexPath) as! ApprovalSelectInfoWeCMSCell
                cell.configCell(data: data, imageSet: self.requestApprovers)
                return cell
            default:
                return UITableViewCell()
            }
            
        case .EXPENSEAPPROVAL:
            let data = self.editDraftVM.expenseApproval[indexPath.row]
            switch data.ApprovalItem {
            case .CONTENT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalFormHeaderCell", for: indexPath) as! ApprovalFormHeaderCell
                
                if isFirstLoaded {
                    getExistedMentionedMember(content: data.Description ?? "")
                }
                if isFirstLoaded {
                    isFirstLoaded = false
                }
                
                cell.titleTextView.delegate = self
                cell.descriptionTextView.delegate = self
                cell.titleTextView.tag = 1000
                cell.descriptionTextView.tag = 1001
                cell.titleTextView.textColor        = .label
//                cell.descriptionTextView.textColor  = .label
                cell.textCountLabel.textColor       = .gray
                cell.descriptionTextView.inputAccessoryView = TopBarKeyboardView
                let tableViewHeight = tableView.frame.size.height
                cell.textCountBottomConstraint.constant = tableViewHeight - self.Spacing
                cell.configDraft(data: data, isArticle: false)
                return cell
            case .IMAGE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageViewWeCMSCell", for: indexPath) as! ImageViewWeCMSCell
                cell.configImageDraft(data: data)
                cell.deleteButton.didTap {
                    self.indexImage = indexPath.row - 1 //> Seanghay <\\ -1 for ApprovalFormHeaderCell
                    for (index,item) in self.editDraftVM.imageIntPairs.enumerated() {
                        if item.FILE_DATA == self.editDraftVM.expenseApproval[indexPath.row].fileData {
                            self.editDraftVM.imageIntPairs.remove(at: index)
                        }
                    }
                    if self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentREC[self.indexImage].FILE_NM}).count > 0 {
                        let fileID = self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentREC[self.indexImage].FILE_NM}).first?.FILE_ID
                        self.deleteFILEREC.append(MREC_BLTB_0004_C002.REQUEST.REC5(FILE_ID: fileID))
                    }
                    self.editDraftVM.expenseApproval.remove(at: indexPath.row)
                    self.editDraftVM.attacmentREC.remove(at: self.indexImage)
//                    self.imageREC.remove(at: self.indexImage)
                    self.Spacing = self.tableView.frame.size.height - self.Spacing
                    for imgUr in self.editDraftVM.attacmentREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                        self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*CGFloat(cell.imageContainView.frame.height)
                    }
                    if self.editDraftVM.attacmentREC.count > 0 {
                        self.Spacing = self.tableView.frame.size.height - CGFloat(self.editDraftVM.attacmentREC.count*46)  //> Seanghay <\\ 46 height of Attachment
                    }else if self.editDraftVM.attacmentREC.count == 0{
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
                    if self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentREC[self.indexImage].FILE_NM}).count > 0 {
                        let fileID = self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentREC[self.indexImage].FILE_NM}).first?.FILE_ID
                        self.deleteFILEREC.append(MREC_BLTB_0004_C002.REQUEST.REC5(FILE_ID: fileID))
                    }
                    self.editDraftVM.expenseApproval.remove(at: indexPath.row)
                    self.editDraftVM.attacmentREC.remove(at: indexFile)
                    self.Spacing = self.tableView.frame.size.height - self.Spacing
                    for imgUr in self.editDraftVM.attacmentREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                        self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*350//> Seanghay <\\ height of image
                    }
                    if self.editDraftVM.attacmentREC.count > 0 {
                        self.Spacing = self.tableView.frame.size.height - CGFloat(self.editDraftVM.attacmentREC.count*46)  //> Seanghay <\\ 46 height of Attachment
                    }else if self.editDraftVM.attacmentREC.count == 0{
                        self.Spacing = self.spceAfterText
                    }
                    self.tableView.reloadData()
                }
                return cell
            case .LINE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalLineCell", for: indexPath) as! ApprovalLineCell
                return cell
            case .DOCUMENTNO:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalInfoWeCMSCell", for: indexPath) as! ApprovalInfoWeCMSCell
                cell.amountStackView.isHidden = true
                cell.configCell(data: data)
                return cell
            case .REQUESTOR:
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentNoWeCMSCell", for: indexPath) as! DocumentNoWeCMSCell
//                cell.amountStackView.isHidden = true
                cell.configCell(data: data)
                return cell
            case .REQUESTSCHEDULED:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalDateInfoWeCMSCell", for: indexPath) as! ApprovalDateInfoWeCMSCell
                let today = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium

                let formattedDate = dateFormatter.string(from: today)
                cell.configDraftCell(data: data, PAY_DATE: self.editDraftVM.responseDraft?.PAY_DATE ?? "",PAY_REQ_DATE: self.editDraftVM.responseDraft?.PAY_REQ_DATE ?? "")
                
                cell.selectDateButton.didTap {
                    self.dropDownSelectDate(date: cell.selectDateButton.titleLabel?.text ?? "") { option in
                        cell.selectDateButton.setTitle(option == "" ? today.toString(format: "dd MMM yyyy") : option, for: .normal)
                        self.PAY_DATE = changeFormatDate(option == "" ? today.toString(format: "dd MMM yyyy") : option, fromFormat: "dd MMM yyyy", toFormat: "yyyyMMdd")
                    }
                }
                cell.dataImageView.image = UIImage(named: data.Image ?? "")
                return cell
            case .TOTALAMOUNT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalInfoWeCMSCell", for: indexPath) as! ApprovalInfoWeCMSCell
                //> Seanghay <\\ for vietnam version
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
//                cell.purposeButton.addTarget    (self, action: #selector(selectedPurpose), for: .touchUpInside)
//                cell.purposeDropButton.addTarget(self, action: #selector(selectedPurpose), for: .touchUpInside)
                cell.deleteButton.didTap {
                    
                    let tempData1 = OptionPopupWithoutTitleModel(title: "delete".localized)
                    let tempData2 = OptionPopupWithoutTitleModel(title: "Don't_delete".localized)
                    let dataItem = [tempData1, tempData2]
                    let title = "delete_expense?".localized
                    self.switchOption(optionData: dataItem, title: title, description: "this_action_cannot_be_undone.".localized) { str in
                        if str == "delete".localized {
                            self.editDraftVM.expenseApproval.remove(at: indexPath.row)
                            for (index, item) in self.editDraftVM.requestExpense.enumerated() {
                                if item.DOC_ID == data.DOC_ID {
                                    self.editDraftVM.requestExpense.remove(at: index)
                                }
                            }
                            self.calculateTotalAmount(data: self.simpleApprovalVM.requestExpense)
                            self.editDraftVM.injectDataWeCMS(isFromApprover: true)
                            self.tableView.reloadData()
                            self.dismiss(animated: true)
                        }else{
                            self.dismiss(animated: true)
                        }
                    }
                }
                return cell
            case .SEEMORE:
                return tableView.dequeueReusableCell(withIdentifier: "SeeMoreCell", for: indexPath) as! SeeMoreCell
                
            default:
                return UITableViewCell()
            }

        case .NEWARTICLE:
            let data = self.editDraftVM.newArticleApproval[indexPath.row]
            switch data.ApprovalItem {
            case .CONTENT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalFormHeaderCell", for: indexPath) as! ApprovalFormHeaderCell
                if isFirstLoaded {
                    getExistedMentionedMember(content: data.Description ?? "")
                }
                if isFirstLoaded {
                    isFirstLoaded = false
                }
                
                cell.titleTextView.delegate         = self
                cell.descriptionTextView.delegate   = self
                cell.titleTextView.tag              = 1000
                cell.descriptionTextView.tag        = 1001
                cell.titleTextView.textColor        = .label
                cell.textCountLabel.textColor       = .gray
                cell.descriptionTextView.inputAccessoryView = TopBarKeyboardView
                cell.textCountBottomConstraint.constant = tableView.frame.size.height - self.Spacing
                cell.configDraft(data: data, isArticle: true)
                return cell
            case .IMAGE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ImageViewWeCMSCell", for: indexPath) as! ImageViewWeCMSCell
                cell.configImageDraft(data: data)
                cell.deleteButton.didTap {
                    self.indexImage = indexPath.row - 1 //> Seanghay <\\ -1 for ApprovalFormHeaderCell
                    for (index,item) in self.editDraftVM.imageIntPairs.enumerated() {
                        if item.name == self.editDraftVM.newArticleApproval[indexPath.row].fileName {
                            self.editDraftVM.imageIntPairs.remove(at: index)
                        }
                    }
                    if self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentArticleREC[self.indexImage].FILE_NM}).count > 0 {
                        let fileID = self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentArticleREC[self.indexImage].FILE_NM}).first?.FILE_ID
                        self.deleteFileArticleREC.append(MREC_BLTB_0004_C001.REQUEST.REC3(FILE_ID: fileID))
                    }
                    self.editDraftVM.newArticleApproval.remove(at: indexPath.row)
                    self.editDraftVM.attacmentArticleREC.remove(at: self.indexImage)
//                    self.imageREC.remove(at: self.indexImage)
                    self.Spacing = self.tableView.frame.size.height - self.Spacing
                    for imgUr in self.editDraftVM.attacmentArticleREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                        self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*CGFloat(cell.imageContainView.frame.height) //> Seanghay <\\ 350 height of image
                    }
                    if self.editDraftVM.attacmentArticleREC.count > 0 {
                        self.Spacing = self.tableView.frame.size.height - CGFloat(self.editDraftVM.attacmentArticleREC.count*46) //> Seanghay <\\ 46 height of Attachment
                    }else if self.editDraftVM.attacmentArticleREC.count == 0{
                        self.Spacing = self.spceAfterText
                    }
                    
                    self.tableView.reloadData()
                }
                return cell
            case .ATTACMENT:
                let cell = tableView.dequeueReusableCell(withIdentifier: "AttactMentsWeCMSCell", for: indexPath) as! AttactMentsWeCMSCell
                cell.deleteButton.didTap {
                    let indexImage = indexPath.row - 1 //> Seanghay <\\ -1 for ApprovalFormHeaderCell
                    if self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentArticleREC[self.indexImage].FILE_NM}).count > 0 {
                        let fileID = self.editDraftVM.fileREC.filter({ $0.ORG_FILE_NM == self.editDraftVM.attacmentArticleREC[self.indexImage].FILE_NM}).first?.FILE_ID
                        self.deleteFileArticleREC.append(MREC_BLTB_0004_C001.REQUEST.REC3(FILE_ID: fileID))
                    }
                    self.editDraftVM.newArticleApproval.remove(at: indexPath.row)
                    self.editDraftVM.attacmentArticleREC.remove(at: indexImage)
                    self.Spacing = self.tableView.frame.size.height - self.Spacing
                    for imgUr in self.editDraftVM.attacmentArticleREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}) {
                        self.Spacing = self.tableView.frame.size.height - CGFloat((imgUr.FILE_NM ?? "").count)*350 //> Seanghay <\\ height of image
                    }
                    
                    if self.editDraftVM.attacmentArticleREC.count > 0 {
                        self.Spacing = self.tableView.frame.size.height - CGFloat(self.editDraftVM.attacmentREC.count*46)
                    }else if self.editDraftVM.attacmentArticleREC.count == 0{
                        self.Spacing = self.spceAfterText
                    }
                    self.tableView.reloadData()
                }
                cell.configFile(data: data)
                return cell
            case .LINE:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ApprovalLineCell", for: indexPath) as! ApprovalLineCell
                return cell
            case .POST:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleToggleCell", for: indexPath) as! ArticleToggleCell
                cell.itemSwitch.isOn = self.POST_STTS == "PL" ? true : false
                cell.specificDateButton.isHidden    = true
                cell.itemSwitch.addTarget(self, action: #selector(switchChanged), for: UIControl.Event.valueChanged)
                cell.configureCell(data: data)
                return cell
            case .MARK:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleToggleCell", for: indexPath) as! ArticleToggleCell
                cell.configureMarkCell(data: data, PIN_POST_TYPE: self.PIN_POST_TYPE, PIN_POST_DUE_DT: self.PIN_POST_DUE_DT)
                if #available(iOS 14.0, *) {
                    cell.itemSwitch.setOnValueChangeListener {
                        let switchOn = cell.itemSwitch.isOn
                        if self.PIN_POST_DUE_DT == "permanently".localized || self.PIN_POST_DUE_DT == ""{
                            self.PIN_POST_TYPE = switchOn ? "UD" : ""  // => if on toggle = "UD" & off toggle = ""
                        }else{
                            self.PIN_POST_TYPE = switchOn ? "LD" : ""  // => if on toggle = "LD" & off toggle = ""
                        }
                        self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none)
                    }
                } else {
                    cell.itemSwitch.addTarget(self, action: #selector(switchChangeMark), for: UIControl.Event.valueChanged)
                }
                cell.specificDateButton.didTap {
                    self.selectDateType = self.PIN_POST_TYPE == "LD" ? "until_specific_date".localized : "save_permanently".localized
                    
                    self.selectOptionWithChekSpecificDate(optionData: changeFormatDate(self.PIN_POST_DUE_DT, fromFormat: "yyyyMMdd", toFormat: "dd-MM-yyyy"), defaultApproval: self.selectDateType ){ option,value,duration   in
                        cell.specificDateButton.setTitle(value, for: .normal)
                        self.PIN_POST_DUE_DT     = duration == "UD" ? value : changeFormatDate(value, fromFormat: "dd MMM yyyy", toFormat: "yyyyMMdd")
                        self.selectDateType     = option
                        self.PIN_POST_TYPE      = duration
                        self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
                        
                    }
                }
                return cell
            default:
                return UITableViewCell()
            }
        }
            
        case self.mentionTableView:
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
            // Main TableView
        case self.tableView:
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
            
        case self.mentionTableView:
            return nil
            
        default:
            return nil
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
        case self.tableView:
            if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
                cell.descriptionTextView.becomeFirstResponder()
            }
            switch approvalType {
            case .SIMPLEAPPROVAl:
                let data = self.editDraftVM.simpleApproval[indexPath.row]
                switch data.ApprovalItem {
                case .APPROVERS:
                    self.popSelectApprovalItem(selectCount: self.editDraftVM.selectApproversCount, selectData: self.requestApprovers, BLTB_CD: "", optionType: .APPROVERS) { option,data  in
                        if tableView.dequeueReusableCell(withIdentifier: "ApprovalSelectInfoWeCMSCell") is ApprovalSelectInfoWeCMSCell {
                            self.editDraftVM.selectApproversCount = option
                            self.requestApprovers = data
                            self.editDraftVM.injectDataWeCMS(isFromApprover: true)
                            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none)
                        }
                    }
                case .IMAGE:
                    self.previewImage()
                default:
                    print("KOKO")
                }
            case .EXPENSEAPPROVAL:
                let data = self.editDraftVM.expenseApproval[indexPath.row]
                switch data.ApprovalItem {
                case .APPROVERS:
                    self.popSelectApprovalItem(selectCount: self.editDraftVM.selectApproversCount, selectData: self.requestApprovers, optionType: .APPROVERS) { option,data  in
                        if tableView.dequeueReusableCell(withIdentifier: "ApprovalSelectInfoWeCMSCell") is ApprovalSelectInfoWeCMSCell {
                            self.editDraftVM.selectApproversCount = option
                            self.requestApprovers = data
                            self.editDraftVM.injectDataWeCMS(isFromApprover: true)
                            self.tableView.reloadRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .none)
                        }
                    }
                case .EXPENSES:
                    self.popSelectApprovalItemExpenseWeCMS(selectCount: self.editDraftVM.selectExpenseCount, filterDateBill: self.filterType, filterDateReceipt: self.filterType, selectData: self.editDraftVM.requestExpense, selectType: self.selectType) { option,filterBill,filterReceipt,data,selectType   in
                        self.calculateTotalAmount(data: data)
                        self.selectType         = selectType
                        self.filterType = filterBill
                        self.requestExpense = data
                        self.editDraftVM.requestExpense = data
                        self.editDraftVM.injectDataWeCMS(isFromApprover: true)
                        self.tableView.reloadData()
                    }
                case .EXPENSESITEM:
                    if data.DOC_TYPE == "E"{
                        //TODO
                        let vc = UIStoryboard(name: "ReceiptDetailsSB", bundle: nil).instantiateViewController(withIdentifier: "ReceiptDetailsVC") as! ReceiptDetailsVC
                        vc.doc_id = self.editDraftVM.expenseApproval[indexPath.row].DOC_ID ?? ""
                        vc.isRequestApproval = true
                        
                        let nav = UINavigationController(rootViewController: vc)
                        nav.modalPresentationStyle = .custom
                        self.present(nav, animated: true)
                    }else if data.DOC_TYPE == ""{
                        self.popAddOtherManual()
                    }
                case .IMAGE:
                    self.currentIndexImage = indexPath.row - 1 //- 1 cuz index 0 is title & desc
                    self.previewImage()
                case .SEEMORE:
                    self.expenseListPop(optionData: self.editDraftVM.requestExpense, isCreate: true) { data in
                        self.calculateTotalAmount(data: data)
                        self.editDraftVM.requestExpense = data
                        self.editDraftVM.selectExpenseCount = "\(data.count)"
                        self.editDraftVM.injectDataWeCMS(isFromApprover: true)
                        self.tableView.reloadData()
                    }
                default:
                    print("KOKO")
                }
                
            case .NEWARTICLE:
                let data = self.editDraftVM.newArticleApproval[indexPath.row]
                switch data.ApprovalItem {
                case .IMAGE:
                    self.previewImage()
                default:
                    print("KOKO")
                }
            }
            
            
        case self.mentionTableView:
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
                
                    if cursorPosition == existedText.utf16.count || existedText.utf16.count == (cursorPosition + 1) {
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
                    self.POST_CONT  = newText
                    
                    
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
extension EditDraftWeCMSVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Title" || textView.text == "Description (max. 200 characters)" {
            textView.text = ""
            let point           = textView.convert(CGPoint.zero, to: self.tableView)
            let indexPath       = self.tableView.indexPathForRow(at: point)!
            if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
                cell.titleTextView.placeholderText = "Title"
                cell.descriptionTextView.placeholderText = "Description (max. 200 characters)"
            }
        }
        self.TopBarKeyboardView.setCountFile(self.editDraftVM.attacmentREC.count)
    }
    func textViewDidChangeSelection(_ textView: UITextView) {
//        var tempDataInfo = (OT_request_vm.contentData[indexPath.row].value as? OT_request_content_body.ContentBody)
//
//        tempDataInfo?.reason?.value = textView.text
//
//        OT_request_vm.contentData[indexPath.row].value = tempDataInfo
    }

//    func textViewDidEndEditing(_ textView: UITextView) {
////        let tempDataInfo = (OT_request_vm.contentData[indexPath.row].value as? OT_request_content_body.ContentBody)
//        let point           = textView.convert(CGPoint.zero, to: self.tableView)
//        let indexPath       = self.tableView.indexPathForRow(at: point)!
//        if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
//            self.POST_TITLE = cell.titleTextView.text ?? ""
//            self.POST_CONT  = cell.descriptionTextView.text ?? ""
//            print("JES", self.POST_TITLE, self.POST_CONT)
////            if textView.text.isEmpty {
////                switch approvalType {
////                case .EXPENSEAPPROVAL, .SIMPLEAPPROVAl:
////                    cell.titleTextView.placeholderText = "Title"
////                    cell.descriptionTextView.placeholderText = "Description (max. 200 characters)"
////                case .NEWARTICLE, .NEWARTICLEONLY:
////                    cell.titleTextView.placeholderText = "Title"
////                    cell.descriptionTextView.placeholderText = "Description"
////                }
////            }
//        }
//    }
    
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
        let count = textView.text.count
        if textView == cell?.titleTextView {
            let height = cell?.titleTextView.heightConstraint?.constant ?? 0
            if height < self.heightTitle {
                let wasteHeight = self.heightTitle - height
                self.Spacing = Spacing - wasteHeight // spacing for Title
                self.spceAfterText = self.Spacing
                cell?.textCountBottomConstraint.constant = cell?.textCountBottomConstraint.constant ?? 0 <= 20 ? 20 : tableView.frame.size.height - self.Spacing
            }
            if text == "\n"{
                let wasteHeight = self.heightTitle - height
                self.Spacing = Spacing + wasteHeight // spacing for Title
                self.spceAfterText = self.Spacing
                cell?.textCountBottomConstraint.constant = cell?.textCountBottomConstraint.constant ?? 0 <= 20 ? 20 : tableView.frame.size.height - self.Spacing
                
            }
            self.heightTitle = height
        }else if textView == cell?.descriptionTextView {
            let height = cell?.descriptionTextView.heightConstraint?.constant ?? 0
            if height < self.heightContent {
                let wasteHeight = self.heightContent - height
                self.Spacing = Spacing - wasteHeight // spacing for Title
                self.spceAfterText = self.Spacing
                cell?.textCountBottomConstraint.constant = cell?.textCountBottomConstraint.constant ?? 0 <= 20 ? 20 : tableView.frame.size.height - self.Spacing
            }
            if text == "\n"{
                let wasteHeight = self.heightContent - height
                self.Spacing = Spacing + wasteHeight // spacing for Description
                self.spceAfterText = self.Spacing
                cell?.textCountBottomConstraint.constant = cell?.textCountBottomConstraint.constant ?? 0 <= 20 ? 20 : tableView.frame.size.height - self.Spacing
            }
            self.heightContent = height
            cell?.textCountLabel.text        = "\(count)/200"
            cell?.textCountLabel.textColor   = .gray
        }else{
                print("OTHER VIEW")
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
                    print("Typing Word Last: ", typingWord)
                    
                    
                } else {
                    let split = updatedString?.components(separatedBy: " ")
                    typingWord = split?.last ?? ""
                    print("Typing Word Last: ", typingWord)
                }
                
                
                if mentionedMemberNames.count > 0 {
                    let originalFont =  UIFont(name: "Inter-Medium", size: 15.0)
                    self.setAttributeTextView(textView: textView, textsTobeAttributed: mentionedMemberNames, defaultFont: originalFont, defaultColor: .black, attributedFont:originalFont , atrributedColor: UIColor(resource: .mainTextBulletin))
                }
                print("Typing Word Last: ", typingWord)
                
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
                
                print("Middle typing String; ", typingWord)
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
                let body =  MREC_BLTB_0004_R001.REQUEST(BLTB_CD: BLTB_CD, USER_NM: stringToSearch.removing(charactersOf: "@"))
                self.mentionMemberVM.requestMentionMembers(body: body) { result in
                    switch result {
                    case .success(_):
                        
                        self.mentionTableView.reloadData()
                        
                        // Show or Hide tableView
                        if self.mentionMemberVM.filteredList.count != 0 {
                            let divided = self.screenHeight / 3
                            self.mentionTableViewHC.constant = self.screenHeight - divided + 10
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
        switch approvalType {
        case .EXPENSEAPPROVAL, .SIMPLEAPPROVAl:
            return textView == cell?.descriptionTextView ? newText.count <= 200 : true
        case .NEWARTICLE:
            return true
            
        }
    }
}

//MARK: - TopBarKeyboardDelegate
extension EditDraftWeCMSVC: TopBarKeyboardDelegate {
    func addFile(_ files: [FileModel]) {
        print(files)
        for file in files {
            switch approvalType {
            case .EXPENSEAPPROVAL, .SIMPLEAPPROVAl:
                self.editDraftVM.attacmentREC.append(MREC_BLTB_0004_C002.REQUEST.REC3(FILE_NM: file.fileName, FILE_DATA: "\(file.fileData)"))
                self.Spacing = self.Spacing + CGFloat(self.simpleApprovalVM.attacmentArticleREC.count*46)
               if self.editDraftVM.attacmentArticleREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}).count > 0 {
                    self.Spacing = self.tableView.frame.size.height - 20
                }
                TopBarKeyboardView.setCountFile(self.editDraftVM.attacmentREC.count)
            case .NEWARTICLE:
                self.editDraftVM.attacmentArticleREC.append(MREC_BLTB_0004_C001.REQUEST.REC(COPY_FILE_YN: nil, FILE_NM: file.fileName, FILE_DATA: "\(file.fileData)"))
                self.Spacing = self.Spacing + CGFloat(self.simpleApprovalVM.attacmentArticleREC.count*46)
                if self.editDraftVM.attacmentArticleREC.filter( {($0.FILE_NM ?? "").contains(".jpg")}).count > 0 {
                    self.Spacing = self.tableView.frame.size.height - 20
                }
                TopBarKeyboardView.setCountFile(self.editDraftVM.attacmentArticleREC.count)
            }
        }
        
        self.editDraftVM.injectDataWeCMS(isFromApprover: true)
        self.tableView.reloadData()
    }
    
    func addImage(_ images: [UIImage]) {
        if images.count != 0 {
            for (i, image) in images.enumerated() {
                if let base64 = convertToBase64(image) {
                    let formatter           = DateFormatter()
                    formatter.dateFormat    = "yyyMMddHHmm"
                    switch approvalType {
                    case .EXPENSEAPPROVAL, .SIMPLEAPPROVAl:
                        self.editDraftVM.attacmentREC.append(MREC_BLTB_0004_C002.REQUEST.REC3(FILE_NM: "\(formatter.string(from: Date()))\(i).jpg", FILE_DATA: base64))
                        self.editDraftVM.imageIntPairs.append(ImageFullSizeDraft(image: image, name: "\(formatter.string(from: Date()))\(i).jpg"))
                        TopBarKeyboardView.setCountFile(self.editDraftVM.attacmentREC.count)
                    case .NEWARTICLE:
                        self.editDraftVM.attacmentArticleREC.append(MREC_BLTB_0004_C001.REQUEST.REC(FILE_NM: "\(formatter.string(from: Date()))\(i).jpg", FILE_DATA: base64))
                        self.editDraftVM.imageIntPairs.append(ImageFullSizeDraft(image: image, name: "\(formatter.string(from: Date()))\(i).jpg"))
                        TopBarKeyboardView.setCountFile(self.editDraftVM.attacmentArticleREC.count)
                    }
                }
            }
        }
        self.Spacing = self.tableView.frame.size.height - 20

        self.editDraftVM.injectDataWeCMS(isFromApprover: true)
        self.tableView.reloadData()
    }
    
    func dismissKeyboard() {
        let point           = tableView.convert(CGPoint.zero, to: self.tableView)
        let indexPath       = self.tableView.indexPathForRow(at: point)!
        if let cell = self.tableView.cellForRow(at: indexPath) as? ApprovalFormHeaderCell {
            cell.descriptionTextView.resignFirstResponder()
        }
    }
    
}
