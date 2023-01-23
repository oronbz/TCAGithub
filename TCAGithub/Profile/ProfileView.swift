//
//  ProfileView.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import SwiftUI

struct ProfileView: View {
    @State var isCommentsPresented = false
    
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.init(
                    red: Double.random(in: 0..<1),
                    green: Double.random(in: 0..<1),
                    blue: Double.random(in: 0..<1)))
                .padding(40)
                        
            Text("Yaniv Cohen")
                .font(.largeTitle)
            
            Spacer()
            
            Button {
                isCommentsPresented = true
            } label: {
                Text("Show comments")
                    .font(.title2)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .padding()
        }
        .sheet(isPresented: $isCommentsPresented) {
            CommentsView()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
