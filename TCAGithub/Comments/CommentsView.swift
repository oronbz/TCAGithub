//
//  CommentsView.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import SwiftUI

struct CommentsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var comment = ""
    
    let comments = [
        "Yaniv is awesome",
        "Yaniv knows how to add margins to a label",
        "Be like Yaniv"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(comments, id: \.self) { comment in
                        Text(comment)
                    }
                }
                .scrollDismissesKeyboard(.immediately)
                
                TextField("Awesome comment...", text: $comment)
                    .onSubmit {
                        comment = ""
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 15)
                                .stroke(.yellow, lineWidth: 2))
                    .background(Color(uiColor: .systemBackground))
                    .padding(10)

            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.down")
                }

            }
        }
    }
}

struct CommentsView_Previews: PreviewProvider {
    static var previews: some View {
        CommentsView()
    }
}
