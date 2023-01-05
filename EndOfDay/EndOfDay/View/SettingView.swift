//
//  SettingView.swift
//  EndOfDay
//
//  Created by 김태성 on 2023/01/05.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    var diary: Diary
    
    @State private var text: String = "초대코드askdjadjklkl"
    @State private var buttonText  = "초대코드 복사하기"
    
    private let pasteboard = UIPasteboard.general
    
    var body: some View {
        List {
            HStack {
                VStack {
                    Image(systemName: "person.3.sequence.fill")
                    Text("일기를 같이 쓰고싶은 친구를 초대하세요!")
                        .padding()
                    
                    // TODO: 다이어리 아이디 복사하기
                    
                    Button {
                        copyToClipboard()
                    } label: {
                        Label(buttonText, systemImage: "doc.on.doc")
                            .modifier(MaxWidthColoredButtonModifier(cornerRadius: 30))
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    
                    
                }
            }
            .padding()
//            .overlay(
//                Rectangle()
//                    .frame(width: UIScreen.main.bounds.width - 30)
//                    .cornerRadius(15)
//                    .foregroundColor(.gray.opacity(0.1))
//            )

            Section(header: Text("함께하는 사람들"), content: {
                ForEach(diary.membersNickname, id: \.self) { nickname in
                    Text(nickname)
                }
//                Text("조운상")
//                Text("이영우")
//                Text("김태성")
            })
            
            // TODO: 일기장 생성 뷰 재사용 가능한지 확인하기
            Button {
                
            } label: {
                Text("일기장 표지 수정")
            }
            
            Button {
                Task {
                    await diaryStore.outDiary(diaryID: diary.id)
                }
            } label: {
                Text("일기장 나가기")
            }
        }
        .listStyle(SidebarListStyle())
        .navigationBarTitle("일기 설정", displayMode: .inline)
    }
    
    
    
    func paste(){
        if let string = pasteboard.string {
            text = string
        }
    }
    
    func copyToClipboard() {
        pasteboard.string = self.text
        
        self.buttonText = "Copied!"
        // self.text = "" // clear the text after copy
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.buttonText = "Copy to clipboard"
        }
    }
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationStack {
//            SettingView()
//        }
//    }
//}


struct MaxWidthColoredButtonModifier: ViewModifier {
    var color: Color = Color("AccentColor")
    var cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .foregroundColor(.white)
            .padding()
            .frame(width: UIScreen.main.bounds.width - 70, height: 44)
            .bold()
            .background(Color.black.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .padding(EdgeInsets(top: 5, leading: 20, bottom: 0, trailing: 20))
    }
}