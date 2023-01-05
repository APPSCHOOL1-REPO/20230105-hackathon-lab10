//
//  DiaryStore.swift
//  EndOfDay
//
//  Created by MIJU on 2022/12/13.
//

import Foundation
import FirebaseFirestore

@MainActor
class DiaryStore: ObservableObject {
    @Published var diaries: [Diary] = []
    
    let database = Firestore.firestore().collection("Diaries")
    
    // MARK: Diary 불러오기
    func fetchDiaries(userID: String) async {
        do {
            let snapshot = try await database.whereField("membersID", arrayContains: userID).getDocuments()
            
            for document in snapshot.documents {
                let docData = document.data()
                let id: String = document.documentID
                let diaryTitle: String = docData["diaryTitle"] as? String ?? ""
                let colorIndex: Int = docData["colorIndex"] as? Int ?? 0
                let createdAt: Double = docData["createdAt"] as? Double ?? 0
                let membersID: [String] = docData["membersID"] as? [String] ?? []
                let diary: Diary = Diary(id: id,dairyTitle: diaryTitle, colorIndex: colorIndex, createdAt: createdAt, membersID: membersID)
                
                self.diaries.append(diary)
            }
            self.diaries = diaries.sorted{ $0.createdAt > $1.createdAt}
            
        } catch{
            fatalError()
        }
    }
    
    // MARK: Diary 만들기
    func addDiary(diary: Diary, userID: String) async {
        do {
            try await database.document(diary.id)
                .setData([
                    "diaryTitle": diary.dairyTitle,
                    "colorIndex": diary.colorIndex,
                    "createdAt": diary.createdAt,
                    "membersID" : [diary.membersID]])
            
            await fetchDiaries(userID: userID)
        } catch {
            fatalError()
        }
    }
    
    // MARK: Diary 초대 수락(그룹 들어가기)
    // 초대코드를 입력하고 버튼을 눌렀을때 실행된다
    func joinDiary(diaryID: String, userID: String) async {
        do {
            let document = try await database.document(diaryID).getDocument()
            guard let docData = document.data() else {return }
            
            // 기존 uid배열에 지금 입력받은 아이디를 추가해준다.
            var membersID: [String] = docData["membersID"] as? [String] ?? []
            membersID.append(userID)
            
            try await database.document(diaryID)
                .updateData([
                    "membersID" : membersID])
            await fetchDiaries(userID: "")
        } catch {
            fatalError()
        }
    }
    
    // MARK: Diary 수정하기
    func editDiary(diary: Diary, userID: String) async {
        do {
            try await database.document(diary.id)
                .setData([
                    "diaryTitle": diary.dairyTitle,
                    "colorIndex": diary.colorIndex,
                    "createdAt": diary.createdAt,
                    "membersID" : [diary.membersID]])
            await fetchDiaries(userID: userID)
        } catch {
            fatalError()
        }
    }
    
    // MARK: Diary 나가기
    func outDiary(diaryID: String, userID: String) async {
        do {
            let document = try await database.document(diaryID).getDocument()
            guard let docData = document.data() else {return }
            
            // 기존 uid배열에 지금 입력받은 아이디를 삭제해준다.
            var membersID: [String] = docData["membersID"] as? [String] ?? []
            guard let removeIndex = membersID.firstIndex(of: userID) else { return }
            membersID.remove(at: removeIndex)
            
            if membersID.isEmpty { // 마지막 사람이 나간경우 일기장을 삭제
                await deleteDiary(diaryID)
            } else {
                try await database.document(diaryID)
                    .updateData([
                        "membersID" : membersID])
            }
            
            await fetchDiaries(userID: "")
            
        } catch {
            fatalError()
        }
    }
    
    // MARK: Diary 삭제
    func deleteDiary(_ diaryID: String) async {
        do {
            try await database.document(diaryID).delete()
        } catch {
            fatalError()
        }
    }
}
