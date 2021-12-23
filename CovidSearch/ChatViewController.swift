//
//  ChatViewController.swift
//  CovidSearch
//
//  Created by 木下健一 on 2021/12/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import MapKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}
struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }
}

class ChatViewController: MessagesViewController, MessagesDataSource, MessageCellDelegate, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    let colors = Colors()
    private var userId = ""
    private var firestoreData:[FirestoreData] = []
    private var messages: [Message] = []
    func currentSender() -> SenderType {
        return Sender(senderId: userId, displayName: "MyName")
    }
    func otherSender() -> SenderType {
        return Sender(senderId: "-1", displayName: "OtherName")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    //text、date、id から Message をイニシャライズして返す
    func createMessage(text: String, date: Date, _ senderId: String) -> Message {
        let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15), .foregroundColor: UIColor.white])
        let sender = (senderId == userId) ? currentSender() : otherSender()
        return Message(attributedText: attributedText, sender: sender as! Sender, messageId: UUID().uuidString, date: date)
    }
    //MARK:MessagesDisplayDelegate
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? colors.blueGreen : colors.redOrenge
    }
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    //messages にメッセージを代入するためにデータを整理
    func getMessages() -> [Message] {
        var messageArray:[Message] = []
        for i in 0..<firestoreData.count {
            messageArray.append(createMessage(text: firestoreData[i].text!, date: firestoreData[i].date!, firestoreData[i].senderId!))
        }
        return messageArray
    }

        

    override func viewDidLoad() {
        super.viewDidLoad()
        Firestore.firestore().collection("Messages").document().setData([
            "date": Date(),
            "senderId": "testId" ,
            "text": "testText" ,
            "userName": "testName"
        ])
        Firestore.firestore().collection("Messages").getDocuments(completion: {
            (document, error) in
            if error != nil {
                print("ChatViewController:Line(\(#line)):error:\(error!)")
            } else {
                if let document = document {
                    for i in 0..<document.count {
                        var storeData = FirestoreData()
                        storeData.date = (document.documents[i].get("date")! as! Timestamp).dateValue()
                        storeData.senderId = document.documents[i].get("senderId")! as? String
                        storeData.text = document.documents[i].get("text")! as? String
                        storeData.userName = document.documents[i].get("userName")! as? String
                        self.firestoreData.append(storeData)
                    }
                }
                self.messages = self.getMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom()
            }
        })

        if let uuid = UIDevice.current.identifierForVendor?.uuidString {
            userId = uuid
            print(userId)
        }
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.contentInset.top = 70
        
        let uiView = UIView()
        uiView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        view.addSubview(uiView)
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = colors.white
        label.text = "Doctor"
        label.frame = CGRect(x: 0, y: 20, width: 100, height: 40)
        label.center.x = view.center.x
        label.textAlignment = .center
        uiView.addSubview(label)
        
        let backButton = UIButton(type: .system)
        backButton.frame = CGRect(x: 10, y: 30, width: 20, height: 20)
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.tintColor = colors.white
        backButton.titleLabel?.font = .systemFont(ofSize: 20)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        uiView.addSubview(backButton)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 70)
        gradientLayer.colors = [colors.bluePurple.cgColor,colors.blue.cgColor,]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        uiView.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    @objc func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ChatViewController: InputBarAccessoryViewDelegate {
    
}
