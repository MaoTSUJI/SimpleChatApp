//
//  ViewController.swift
//  SimpleChatApp
//
//  Created by 辻真緒 on 2019/08/08.
//  Copyright © 2019 辻真緒. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var roomNameTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    // チャットの部屋一覧を保持する配列
    var rooms: [Room] = []{
        // roomsが書き換わった時
        
        didSet {
            // テーブルを更新する
            tableView.reloadData()
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Firestoreへ接続
        let db = Firestore.firestore()
        // コレクションroomが変更されたかどうかを検知するリスナーを登録
        db.collection("room").addSnapshotListener { (querySnapshot, error) in
            
//            print("変更されました")  // 確認用
            // ルームの中身が変更されるたびに、この中身が実行される
            
            // querySnapshot.documents: room内の全件を取得
            guard let documents = querySnapshot?.documents else {
                // roomの中に何もない場合、処理を中断
                return
            }
            
            // 変数documentsにroomの全データがあるので、
            // それを元に配列を作成し、画面を更新する
            var results: [Room] = []
            
            for document in documents {
                
                let roomName = document.get("name") as! String  // get("name")だけやと、Any型でと取得することになる
                let room = Room(name: roomName, documentId: document.documentID)
                
                results.append(room)
                
            }
            // 変数roomsを書き換える
            self.rooms = results
            
        }
        
        
    }

    // ルーム作成のボタンがクリックされた時
    @IBAction func didClickButton(_ sender: UIButton) {
        
        if roomNameTextField.text!.isEmpty {
            // テキストフィールドが空文字の場合
            return // 処理を中断
        }
        
        // 部屋の名前を変数に保存
        let roomName = roomNameTextField.text!
        
        // Firestoreの接続情報取得
        let db = Firestore.firestore()
        
        // Firestoreに新しい部屋を追加
        db.collection("room").addDocument(data: ["name": roomName, "createAt": FieldValue.serverTimestamp()]) {
            
            err in
            
            if let err = err {
                print("チャットるーむの作成に失敗しました")
                print(err)
            } else {
                print("チャットるーむを作成しました:\(roomName)")
            }
            
            
        }
        
        
    }
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    // テーブルに表示する件数を表示する
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    // テーブルに表示する内容を返す（今回はroomの名前を返したい）
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // TableViewのセルの情報を取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // roomsの中の1件を表示する
        let room = rooms[indexPath.row]
        
        cell.textLabel?.text = room.name
        
        // 右矢印の設定
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    
}
