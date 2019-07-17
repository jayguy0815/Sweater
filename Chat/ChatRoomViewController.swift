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


class ChatRoomViewController: MessagesViewController {
    var listener : ListenerRegistration?
    
    var messages: [Message] = []
    
    var channelID : String!
    
    var ref = Firestore.firestore().collection("channels")
    
    var uid : String!
    
    var keyboardHeight : CGFloat!
    
    var isAtForeground = false
    
    var activity : Activity!
    
    var offset = CGPoint(x: 0, y: 0)
    
    @IBOutlet weak var infoView: infoUIView!
    
    @IBOutlet weak var infoBtn: UIBarButtonItem!
    
    @IBAction func InfoBtnPressed(_ sender: UIBarButtonItem) {
        if !isAtForeground {
            infoView.isHidden = false
            self.messagesCollectionView.isUserInteractionEnabled = false
            isAtForeground = true
        } else {
            infoView.isHidden = true
            self.messagesCollectionView.isUserInteractionEnabled = true
            isAtForeground = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        Manager.shared.setNavigationBar()
        messagesCollectionView.addSubview(infoView)
        infoView.isHidden = true
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
        
        
        //print((notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect).height)
    
    @objc func keyBoardDidHide(_ notification:Notification) {
        guard messagesCollectionView.numberOfSections > 0 else { return }
        let lastSection = messagesCollectionView.numberOfSections - 1
        let indexPath = IndexPath(row: 0, section: lastSection)
        messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        self.messageInputBar.inputTextView.resignFirstResponder()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
                if error != nil {
                    print(error)
                }
                guard let fetchedMessages = snapshot?.documents else {
                    return
                }
                
                for message in fetchedMessages{
                    let newMessage = Message()
                    newMessage.senderID = message.get("senderID") as! String
                    newMessage.senderName = message.get("senderName") as! String
                    
                    newMessage.postTime = message.get("postTime") as! Double
                    let timeInterval64 = Int64(exactly: newMessage.postTime!.rounded())
                    newMessage.sendTime = Date(timeIntervalSince1970: TimeInterval(exactly: timeInterval64!)!)
                    newMessage.messageId = message.documentID
                    newMessage.text = message.get("content") as! String
                    self.messages.append(newMessage)
                }
                Manager.shared.saveMessage(key: self.activity.key, messages: self.messages)
                self.messages.sort(by: { (m1, m2)-> Bool in
                    m1.postTime!<m2.postTime!
                })
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
            
            UserDefaults.standard.set(true, forKey: "\(activity.key)")
            UserDefaults.standard.set(self.messages.last?.postTime!, forKey: "\(activity.key)updated")
        }else if UserDefaults.standard.bool(forKey: "\(activity.key)") == true{
            self.messages = Manager.shared.loadMessage(key: activity.key)
            self.messages.sort(by: { (m1, m2)-> Bool in
                m1.postTime!<m2.postTime!
            })
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToBottom()
            UserDefaults.standard.set(self.messages.last?.postTime!, forKey: "\(activity.key)updated")
        }
        
        
        
        messageInputBar.sendButton.title = "傳送"
        messageInputBar.sendButton.tintColor = .primary
        messageInputBar.setRightStackViewWidthConstant(to: 40, animated: false)
        messageInputBar.inputTextView.placeholder = "輸入訊息"
        messageInputBar.inputTextView.layer.cornerRadius = 20
        messageInputBar.inputTextView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 21)!]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = "\(activity.name)(\(activity.participantCounter))"
        
        
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
        
        
        
        self.listener = ref.document("\(activity.key)").collection("messages").whereField("postTime", isGreaterThan: UserDefaults.standard.double(forKey: "\(activity.key)updated")).addSnapshotListener({ (snapshot, error) in
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
                        self.messagesCollectionView.reloadData()
                        self.messagesCollectionView.scrollToBottom(animated: true)
                    })
                }
            })
        })
        
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        
        
        
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
        self.listener?.remove()
        
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
       
        
        ref.document(activity.key).collection("messages").addDocument(data: dic)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.messagesCollectionView.visibleCells.count > 0{
//            UserDefaults.standard.set(messagesCollectionView.contentOffset, forKey: "\(activity.key)offset)")
            let x = Float(messagesCollectionView.contentOffset.x)
            let y = Float(messagesCollectionView.contentOffset.y)
            UserDefaults.standard.set(x, forKey: "\(activity.key).x)")
            UserDefaults.standard.set(y, forKey: "\(activity.key).y)")
        }
    }

}
    


extension ChatRoomViewController : MessagesDisplayDelegate{
    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        
//        let message = messages[indexPath.section]
//        let color = message.member.color
//        avatarView.backgroundColor = color
        if isFromCurrentSender(message: message) {
            if let imagedata = UserDefaults.standard.object(forKey: "userProfileImage") as? Data {
                guard let image = UIImage(data: imagedata) else {
                    return
                }
                avatarView.image = image.resizeImageWith(newSize: CGSize(width: 30, height: 30))
            }
            
        } else {
            for account in Manager.shared.accounts {
                if account.uid == message.sender.senderId{
                    let image = account.image?.resizeImageWith(newSize: CGSize(width: 30, height: 30))
                    avatarView.image = image
                }
            }
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
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .topRight : .topLeft
        
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
    
   
    func currentSender() -> SenderType {
        
        
        return Sender(id: self.uid, displayName: Manager.shared.userAccount.nickname)
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageTopLabelHeight(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 12
    }
    
//    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 8
//    }
    
    func messageTopLabelAttributedText(
        for message: MessageType,
        at indexPath: IndexPath) -> NSAttributedString? {
        let nSAttributedString = NSAttributedString(
            string: message.sender.displayName,
            attributes: [.font: UIFont.systemFont(ofSize: 12)])
        return nSAttributedString
    }
  
//    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//
//    }
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.lightGray.withAlphaComponent(0.6)
        attributes[.font] =  UIFont.systemFont(ofSize: 10)
        let timeInterval = messages[indexPath.section].postTime! as! TimeInterval
        let d = Date(timeIntervalSince1970: timeInterval)
        
        let df = DateFormatter()
        df.dateFormat = "HH-mm"
        let dateText = df.string(from: d)
        return NSAttributedString(string: dateText , attributes: attributes)
    }
    
    

}

extension ChatRoomViewController : MessageInputBarDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        guard let nickName = UserDefaults.standard.string(forKey: "userNickName") else {
            return
        }

        let newMessage = Message()
        newMessage.senderID = uid
        newMessage.senderName = nickName
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



