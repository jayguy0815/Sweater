//
//  ChatRoomViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/4.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import IQKeyboardManagerSwift
import NotificationCenter
import Photos
import CoreData


class ChatRoomViewController: MessagesViewController, ManagerDelegate{
    func didFinishListen() {
        self.messagesCollectionView.reloadDataAndKeepOffset()
    }
    
    var listener : ListenerRegistration?
    
    var activityListener : ListenerRegistration?
    
    var messages: [Message] = []
    
    var channelID : String!
    
    var ref = Firestore.firestore().collection("channels")
    
    var uid : String!
    
    var keyboardHeight : CGFloat!
    
    var isAtForeground = false
    
    var account : [Account] = []
    
    var activity : Activity!
    
    var offset = CGPoint(x: 0, y: 0)
    
    var tapGestureRecognizer : UITapGestureRecognizer!
    
    var titletapped = false
    
    
    
    var collectionView : UICollectionView!
    @IBOutlet weak var collectionViewHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var peopleCollectionView: UICollectionView!
    
    @IBOutlet weak var infoView: infoUIView!
    
    @IBOutlet weak var infoBtn: UIBarButtonItem!
    
    @IBAction func InfoBtnPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "detailSegue", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        tapGestureRecognizer = UITapGestureRecognizer(target:self, action: #selector(self.navBarTapped(_:)))
        
        self.navigationController?.navigationBar.addGestureRecognizer(tapGestureRecognizer)

        IQKeyboardManager.shared.enable = false
        messagesCollectionView.scrollToBottom(animated: false)
       
    }
    
    @objc func navBarTapped(_ theObject: AnyObject){
        
        print("Hey there")

        if self.titletapped == false{
            self.view.bringSubviewToFront(peopleCollectionView)
            let ds = DS(activity: self.activity,participates: self.account)
            self.peopleCollectionView.dataSource = ds
            self.peopleCollectionView.delegate = ds
            self.peopleCollectionView.backgroundColor = UIColor(named: "barGreen")
            UIView.animate(withDuration: 0.3, animations: {
                self.collectionViewHeightCons.constant = 40
                self.view.layoutIfNeeded()
            }) { (success) in
                if success == true{
                }
            }
           
            
           
            self.titletapped = true
        }else{
            UIView.animate(withDuration: 0.3) {
                self.collectionViewHeightCons.constant = 0
                self.view.layoutIfNeeded()
                self.peopleCollectionView.layoutSubviews()
            }
            self.titletapped = false
        }
    }
    @objc func removeFromSuper(){
        self.collectionView.removeFromSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.title = "\(self.activity.name)(\(self.activity.participantCounter))"
        
        if UserDefaults.standard.bool(forKey: "\(activity.key)performSegue") == true{
            UserDefaults.standard.set(false, forKey: "\(activity.key)performSegue")
            
            self.listener = ref.document("\(activity.key)").collection("messages").whereField("postTime", isGreaterThan: UserDefaults.standard.double(forKey: "\(activity.key)updated")).addSnapshotListener({ (snapshot, error) in
                print("b")
                print("start listen")
                if error != nil {
                    print(error)
                }
                guard let querySnapshot = snapshot else {
                    return
                }
                querySnapshot.documentChanges.forEach({ (diff) in
                    if diff.type == .added{
                        let newMessage = Message()
                        newMessage.senderID = diff.document.get("senderID") as? String
                        newMessage.senderName = diff.document.get("senderName") as? String
                        newMessage.sendTime = diff.document.get("SendDate") as? Date
                        newMessage.postTime = diff.document.get("postTime") as? Double
                        newMessage.messageId = diff.document.documentID
                        newMessage.text = diff.document.get("content") as? String
                        
                        self.messages.append(newMessage)
                        Manager.shared.saveMessage(key: self.activity.key, messages: self.messages)
                        self.messages.sort(by: { (m1, m2)-> Bool in
                            m1.postTime!<m2.postTime!
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+3.0, execute: {
                            Manager.shared.read(activityID: self.activity.key)
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToBottom(animated: true)
                        })
                    }
                })
            })
        }
        
        
        self.activityListener = Firestore.firestore().collection("activities").document(self.activity.key).addSnapshotListener({ (snapshot, error) in
            print("a")
            if let err = error {
                print(err)
            }
            guard let queryActivity = snapshot?.data() else {
                return
            }
            let name = queryActivity["activityName"] as! String
            let count = queryActivity["participateCounter"] as! Int
            self.navigationItem.title = "\(name)(\(count))"
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
            request.predicate = NSPredicate(format:"(key = %@)", (self.activity.key))
            
            do {
                let results = try CoreDataHelper.shared.managedObjectContext().fetch(request)  as! [Activity]
                
                if results.count > 0 {
                    results[0].unread = false
                    CoreDataHelper.shared.saveContext()
                    
                }
            } catch {
                fatalError("\(error)")
            }
            self.messagesCollectionView.reloadDataAndKeepOffset()
            let users = Manager.shared.queryAccountFromCoreData()
            self.account.removeAll()
            for i in 0..<users.count{
                if self.activity.participants.contains(users[i].uid){
                    self.account.append(users[i])
                }
            }
            self.account.sort(by: { (a1, a2) -> Bool in
                a1.postTime>a2.postTime
            })
                let ds = DS(activity: self.activity, participates: self.account)
                self.peopleCollectionView.delegate = ds
                self.peopleCollectionView.reloadData()
                self.peopleCollectionView.layoutSubviews()
            
            
            
        })
        
       
        
        
        
        
       
        messagesCollectionView.addSubview(infoView)
        infoView.isHidden = true
        
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.height)!, width: UIScreen.main.bounds.width, height: 50), collectionViewLayout: UICollectionViewLayout())
        self.collectionView.backgroundColor = .lightGray
       
        
//        messagesCollectionView.setContentOffset(CGPoint(x: 0, y: messagesCollectionView.contentSize.height), animated: false)
        
        //self.messagesCollectionView.scrollToBottom()
//        if UserDefaults.standard.bool(forKey: "\(activity.key)") == true{
//           let x = CGFloat(UserDefaults.standard.float(forKey: "\(activity.key).x)"))
//            let y = CGFloat(UserDefaults.standard.float(forKey: "\(activity.key).y)"))
//            self.messagesCollectionView.setContentOffset(CGPoint(x: x, y: y), animated: false)
//
//        }
        
        
        
        
    }
    
    @objc func keyBoardWillShow(_ notification:Notification) {
        self.keyboardHeight = (notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect).height-50
        
        let keyboardSize = (notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect).height-50
        guard messagesCollectionView.numberOfSections > 0 else { return }
        let lastSection = messagesCollectionView.numberOfSections - 1
        let indexPath = IndexPath(row: 0, section: lastSection)
        messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)

    }
    
    @objc func keyBoardDidHide(_ notification:Notification) {
        guard messagesCollectionView.numberOfSections > 0 else { return }
        let lastSection = messagesCollectionView.numberOfSections - 1
        let indexPath = IndexPath(row: 0, section: lastSection)
        messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        self.messageInputBar.inputTextView.resignFirstResponder()
    }
    
    @objc func didTapOnCollectionView (recognizer: UITapGestureRecognizer) {
        self.collectionViewHeightCons.constant = 0
        self.view.layoutIfNeeded()
        self.peopleCollectionView.layoutSubviews()
    
        self.titletapped = false
        performSegue(withIdentifier: "memberSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelgate = UIApplication.shared.delegate as! AppDelegate
        appDelgate.delegate = self
        
        Manager.shared.delegate = self
        let backButton = UIBarButtonItem()
        backButton.title = "返回"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        let ds = DS(activity: self.activity, participates: self.account)
       
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapOnCollectionView(recognizer:)))
        tap.numberOfTapsRequired = 1
        self.peopleCollectionView.addGestureRecognizer(tap)
        self.collectionViewHeightCons.constant = 0
        let users = Manager.shared.queryAccountFromCoreData()
        for i in 0..<users.count{
            if self.activity.participants.contains(users[i].uid){
                self.account.append(users[i])
            }
            
        }
        account.sort { (a1, a2) -> Bool in
            a1.postTime>a2.postTime
        }
        
        //self.navigationItem.rightBarButtonItem.fr
        guard let userid = Auth.auth().currentUser?.uid else {
            return
        }
        self.uid = userid
        
        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        if UserDefaults.standard.bool(forKey: "\(activity.key)") == false{
            Firestore.firestore().collection("channels").document("\(activity.key)").collection("messages").order(by: "postTime", descending: false).getDocuments { (snapshot, error) in
                print("message listening")
                if error != nil {
                    print(error)
                }
                guard let fetchedMessages = snapshot?.documents else {
                    return
                }
                
                for i in 0..<fetchedMessages.count{
                    let newMessage = Message()
                    newMessage.senderID = fetchedMessages[i].get("senderID") as! String
                    newMessage.senderName = fetchedMessages[i].get("senderName") as! String
                    
                    newMessage.postTime = fetchedMessages[i].get("postTime") as! Double
                    let timeInterval64 = Int64(exactly: newMessage.postTime!.rounded())
                    newMessage.sendTime = Date(timeIntervalSince1970: TimeInterval(exactly: timeInterval64!)!)
                    newMessage.messageId = fetchedMessages[i].documentID
                    newMessage.text = fetchedMessages[i].get("content") as! String
                    self.messages.append(newMessage)
                    if i == fetchedMessages.count - 1 {
                        UserDefaults.standard.set(self.messages.last?.postTime!, forKey: "\(self.activity.key)updated")
                        self.listener = self.ref.document("\(self.activity.key)").collection("messages").whereField("postTime", isGreaterThan: UserDefaults.standard.double(forKey: "\(self.activity.key)updated")).addSnapshotListener({ (snapshot, error) in
                            print("start listen")
                            if error != nil {
                                print(error)
                            }
                            guard let querySnapshot = snapshot else {
                                return
                            }
                            querySnapshot.documentChanges.forEach({ (diff) in
                                if diff.type == .added{
                                    let newMessage = Message()
                                    newMessage.senderID = diff.document.get("senderID") as? String
                                    newMessage.senderName = diff.document.get("senderName") as? String
                                    newMessage.sendTime = diff.document.get("SendDate") as? Date
                                    newMessage.postTime = diff.document.get("postTime") as? Double
                                    newMessage.messageId = diff.document.documentID
                                    newMessage.text = diff.document.get("content") as? String
                                    self.messages.append(newMessage)
                                    Manager.shared.saveMessage(key: self.activity.key, messages: self.messages)
                                    self.messages.sort(by: { (m1, m2)-> Bool in
                                        m1.postTime!<m2.postTime!
                                    })
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now()+1.0, execute: {
                                        
                                        Manager.shared.read(activityID: self.activity.key)
                                        self.messagesCollectionView.reloadDataAndKeepOffset()
                                        self.messagesCollectionView.scrollToBottom(animated: true)
                                    })
                                }
                            })
                        })
                    }
                }
                Manager.shared.saveMessage(key: self.activity.key, messages: self.messages)
                self.messages.sort(by: { (m1, m2)-> Bool in
                    m1.postTime!<m2.postTime!
                })
                
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
            
            UserDefaults.standard.set(true, forKey: "\(activity.key)")
        }
        else if UserDefaults.standard.bool(forKey: "\(activity.key)") == true{
            self.messages = Manager.shared.loadMessage(key: activity.key)
            self.messages.sort(by: { (m1, m2)-> Bool in
                m1.postTime!<m2.postTime!
            })
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
            self.listener = ref.document("\(activity.key)").collection("messages").whereField("postTime", isGreaterThan: UserDefaults.standard.double(forKey: "\(activity.key)updated")).addSnapshotListener({ (snapshot, error) in
                print("b")
                print("start listen")
                if error != nil {
                    print(error)
                }
                guard let querySnapshot = snapshot else {
                    return
                }
                querySnapshot.documentChanges.forEach({ (diff) in
                    if diff.type == .added{
                        let newMessage = Message()
                        newMessage.senderID = diff.document.get("senderID") as? String
                        newMessage.senderName = diff.document.get("senderName") as? String
                        newMessage.sendTime = diff.document.get("SendDate") as? Date
                        newMessage.postTime = diff.document.get("postTime") as? Double
                        newMessage.messageId = diff.document.documentID
                        newMessage.text = diff.document.get("content") as? String
                        
                        self.messages.append(newMessage)
                        Manager.shared.saveMessage(key: self.activity.key, messages: self.messages)
                        self.messages.sort(by: { (m1, m2)-> Bool in
                            m1.postTime!<m2.postTime!
                        })
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+3.0, execute: {
                            Manager.shared.read(activityID: self.activity.key)
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToBottom(animated: true)
                        })
                    }
                })
            })
        }
        
        
        
        
        messageInputBar.sendButton.title = "傳送"
        messageInputBar.sendButton.tintColor = .primary
        messageInputBar.setRightStackViewWidthConstant(to: 40, animated: false)
        messageInputBar.inputTextView.placeholder = "輸入訊息"
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.inputTextView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        
       
        
        
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .primary
        cameraItem.image = UIImage(named: "cameraIcon")
        cameraItem.setSize(CGSize(width: 40, height: 30), animated: false)
        
        let photoItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .primary
        cameraItem.image = UIImage(named: "photoLibraryIcon")
        cameraItem.setSize(CGSize(width: 40, height: 30), animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setStackViewItems([cameraItem,photoItem], forStack: .left, animated: false)
        messageInputBar.leftStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = true
        
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyBoardDidHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        messagesCollectionView.addGestureRecognizer(singleTap)
        // Do any additional setup after loading the view.
        
        
        
       
        
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        
        
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       print("viewWillDisappear")
        self.navigationController?.navigationBar.removeGestureRecognizer(tapGestureRecognizer)
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
        self.listener?.remove()
        self.activityListener?.remove()
        UserDefaults.standard.set(self.messages.last?.postTime!, forKey: "\(self.activity.key)updated")
        
        
    }
    
    
    deinit {
        
    }
    
    private func insertNewMessage(_ message: Message) {
 
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
        
        //self.messagesCollectionView.reloadData()
        
    }
    
    private func save(_ message: Message) {
        
        let dic : [String:Any] = ["senderID":message.senderID,"senderName":message.senderName ,"content":message.text,"sendDate":message.sendTime,"messageId":message.messageId,"postTime":message.postTime]
        let activityDic : [String:Any] = ["lastMessage":message.text , "lastMessageTime":message.postTime , "modifiedTime":message.postTime]
       
        
        ref.document(activity.key).collection("messages").addDocument(data: dic)
        
        Firestore.firestore().collection("activities").document(activity.key).updateData(activityDic) { (error) in
            if let err = error {
                print(err)
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.messagesCollectionView.visibleCells.count > 0{
            let x = Float(messagesCollectionView.contentOffset.x)
            let y = Float(messagesCollectionView.contentOffset.y)
            UserDefaults.standard.set(x, forKey: "\(activity.key).x)")
            UserDefaults.standard.set(y, forKey: "\(activity.key).y)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailSegue" {
            UserDefaults.standard.set(true, forKey: "\(activity.key)performSegue")
            let detailVC = segue.destination as! DetailViewController
            detailVC.activity = self.activity
        }else if segue.identifier == "memberSegue"{
            UserDefaults.standard.set(true, forKey: "\(activity.key)performSegue")
            let memberVC = segue.destination as! MemberViewController
            memberVC.activity = self.activity
            memberVC.members = self.account
        }
    }

}
    


extension ChatRoomViewController : MessagesDisplayDelegate{
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
        if self.activity.participants.contains(message.sender.senderId){
            for account in self.account{
                if account.uid == message.sender.senderId{
                    let imageData = account.image
                    let image = UIImage(data: imageData)
                    if let img = image{
                        avatarView.image = img.resizeImageWith(newSize: CGSize(width: 30, height: 30))
                    }
                }
            }
           
        }else{
            avatarView.image = UIImage(named: "defaultAccountImage")
        }
        
        
        
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {

        // 1
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        
        // 2
        return true
    }
    
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        // 3
        return .bubbleTail(corner, .curved)
    }
    
    
}

extension ChatRoomViewController : MessagesLayoutDelegate{
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 10
    }
    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        // 2
        return CGSize(width: 0, height: 10)
    }
    
    
    
    func avatarPosition(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> AvatarPosition {
        return AvatarPosition(horizontal: .cellLeading, vertical: .messageLabelTop)
    }
    
    
}




extension ChatRoomViewController : MessagesDataSource {
    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        <#code#>
//    }
//
    func currentSender() -> SenderType {
        var name : String = ""
        for user in Manager.accounts{
            if user.uid == self.uid{
                name = user.nickname
            }
        }
        return Sender(id: self.uid, displayName: name)
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        <#code#>
//    }
    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
//        if self.collectionView != messagesCollectionView{
//            return self.activity.participantCounter
//        }
        return messages.count
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 14
    }
    
//    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 8
//    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        var nSAttributedString = NSAttributedString(
            string: "使用者",
            attributes: [.font: UIFont.systemFont(ofSize: 10)])
//        for user in account {
//            if message.sender.senderId == user.uid{
//                nSAttributedString = NSAttributedString(
//                    string: user.nickname,
//                    attributes: [.font: UIFont.systemFont(ofSize: 10)])
//            }
//        }
        
        if self.activity.participants.contains(message.sender.senderId){
            for account in self.account{
                if account.uid == message.sender.senderId{
                    nSAttributedString = NSAttributedString(
                        string: account.nickname,
                        attributes: [.font: UIFont.systemFont(ofSize: 10)])
                }
            }
            
        }else{
            nSAttributedString = NSAttributedString(
                string: "使用者",
                attributes: [.font: UIFont.systemFont(ofSize: 10)])
        }
        
        
        return nSAttributedString
    }
  
//    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//
//    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.lightGray.withAlphaComponent(0.6)
        attributes[.font] =  UIFont.systemFont(ofSize: 10)
        let timeInterval = messages[indexPath.section].postTime! as! TimeInterval
        let dateText = Manager.shared.timeIntervaltoDatetoString(timeInterval: timeInterval, format: "HH:mm")
        return NSAttributedString(string: dateText , attributes: attributes)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if indexPath.section == 0 {
            return 20
        }else if indexPath.section > 0{
             let timeInterval = messages[indexPath.section].postTime!
            let timeInterval1 = messages[indexPath.section-1].postTime!
            
            let date = Date(timeIntervalSince1970: timeInterval)
            let date1 = Date(timeIntervalSince1970: timeInterval1)
            if date.compare(with: date1, only: .day) == 1 {
                return 20
            }
            
            }else {
                return 0
            }
        return 0
    
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let timeInterval = messages[indexPath.section].postTime!
        let dateText = Manager.shared.timeIntervaltoDatetoString(timeInterval: timeInterval, format: "MM/dd")
        if indexPath.section == 0 {
            return NSAttributedString(string:  dateText, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }else if indexPath.section > 0{
            let timeInterval1 = messages[indexPath.section-1].postTime!
            let date = Date(timeIntervalSince1970: timeInterval)
            let date1 = Date(timeIntervalSince1970: timeInterval1)
            if date.compare(with: date1, only: .day) == 1 {
                let dateText1 = Manager.shared.timeIntervaltoDatetoString(timeInterval: timeInterval, format: "MM/dd")
                return NSAttributedString(string:  dateText1, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
            }else {
                return nil
            }
        }
            
        
        return nil
    }
    
    

}

extension ChatRoomViewController : MessageInputBarDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        var name : String = ""
        for user in Manager.accounts{
            if user.uid == self.uid{
                name = user.nickname
            }
        }
        let newMessage = Message()
        newMessage.senderID = uid
        newMessage.senderName = name
        newMessage.sendTime = Date()
        newMessage.postTime = Date().timeIntervalSince1970
        newMessage.messageId = UUID().uuidString
        newMessage.text = text
        
        
        inputBar.inputTextView.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
            self.save(newMessage)
            self.insertNewMessage(newMessage)
            
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didChangeIntrinsicContentTo size: CGSize) {
       
    }
}

extension ChatRoomViewController : MessageCellDelegate{
    
}

extension UIView{
    func fadeTo(_ alpha: CGFloat, duration: TimeInterval = 1) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: duration) {
                self.alpha = alpha
            }
        }
    }
    
    func fadeIn(_ duration: TimeInterval = 1) {
        fadeTo(1.0, duration: duration)
    }
    
    func fadeOut(_ duration: TimeInterval = 0.3) {
        fadeTo(0.0, duration: duration)
    }
}

extension Date {
    
    func compare(with date: Date, only component: Calendar.Component) -> Int {
        let days1 = Calendar.current.component(component, from: self)
        let days2 = Calendar.current.component(component, from: date)
        return days1 - days2
    }
}

extension ChatRoomViewController : AppDelegateDelegate{
    func didEnterBackground() {
//        UserDefaults.standard.set(self.messages.last?.postTime!, forKey: "\(self.activity.key)updated")
//        self.activityListener?.remove()
//        self.listener?.remove()
        print("back")
    }
    
    func didEnterForeground() {
        print("front")
    }
}

