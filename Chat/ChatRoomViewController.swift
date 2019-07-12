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
    var messages: [Message] = []
    
    var channelID : String!
    
    var ref = Database.database().reference().child("channels")
    
    var uid : String!
    
    var keyboardHeight : CGFloat!
    
    var isAtForeground = false
    
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
        messagesCollectionView.addSubview(infoView)
        infoView.isHidden = true
    }
    
    @objc func keyBoardWillShow(_ notification:Notification) {
        self.keyboardHeight = (notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect).height-50
        
        let keyboardSize = (notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect).height-50
        self.messagesCollectionView.scrollToBottom(animated: true)
//        if self.view.frame.origin.y == 0 {
//            UIView.animate(withDuration: 0.3) {
//                 self.view.frame.origin.y -= keyboardSize
//            }
//        }
    }
        
        
        //print((notification.userInfo?["UIKeyboardBoundsUserInfoKey"] as! CGRect).height)
    
    @objc func keyBoardDidHide(_ notification:Notification) {
        guard messagesCollectionView.numberOfSections > 0 else { return }
        let lastSection = messagesCollectionView.numberOfSections - 1
        let indexPath = IndexPath(row: 0, section: lastSection)
        messagesCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        self.messageInputBar.inputTextView.resignFirstResponder()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        self.uid = uid
        let b : String = "bbb"
        let  handle = ref.child(channelID).child("messages").observe(.value) { (snapshot) in
            self.messages.removeAll()
            if let messageIDDic = snapshot.value as? [String:Any]{
                let messageDic = messageIDDic
                
                let array = Array(messageDic.keys)
                for i in 0..<array.count {
                    let dic = messageDic[array[i]] as! [String:Any]
                    //print(dic)
                    
                    let message = Message(senderID: dic["senderID"] as! String, senderName: dic["senderName"] as! String, text: dic["content"] as! String, sendTime: Manager.shared.stringToDate2(from: dic["sendTime"] as! String), messageId: dic["messageId"] as! String,postTime: dic["postTime"] as! Double)
                
                    self.messages.append(message)
                    self.messages.sort { (m1, m2) -> Bool in
                        m1.postTime<m2.postTime
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now()+1.5, execute: {
                        //self.messagesCollectionView.collectionViewLayout.invalidateLayout()
                        self.messagesCollectionView.reloadData()
                        
                        self.messagesCollectionView.scrollToBottom(animated: true)
                    })
                }
            }
        }
        
        self.navigationController?.tabBarController?.tabBar.isHidden = true
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.scrollToBottom()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        ref.removeAllObservers()
    }
    
    private func insertNewMessage(_ message: Message) {
        
        
        
        
        
        messages.append(message)
//        self.messages.sort { (m1, m2) -> Bool in
//            m1.postTime<m2.postTime
//        }
        
       
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
        
        //self.messagesCollectionView.reloadData()
        
    }
    
    private func save(_ message: Message) {
        
        let dic : [String:Any] = ["senderID":uid,"senderName":message.senderName ,"content":message.text,"sendTime":Manager.shared.dateToString(Date()),"messageId":message.messageId,"postTime":[".sv":"timestamp"]]
       
        
        ref.child(channelID).child("messages").childByAutoId().updateChildValues(dic)
        
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
    
    
//    func avatarSize(for message: MessageType, at indexPath: IndexPath,
//                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
//
//        // 1
//        return .zero
//    }
//
    
    
    
    func avatarPosition(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> AvatarPosition {
        return AvatarPosition(horizontal: .cellLeading, vertical: .messageCenter)
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
        var dateText = Manager.shared.dateToString(messages[indexPath.section].sendTime)
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
        let newMessage = Message(senderID: uid, senderName: nickName , text: text, sendTime: Date(), messageId: UUID().uuidString, postTime: Date().timeIntervalSince1970)
        
        
        
        inputBar.inputTextView.text = ""
//        self.messageInputBar.inputTextView.resignFirstResponder()
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



