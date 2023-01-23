//
//  SearchView.swift
//  TCAGithub
//
//  Created by Oron Ben Zvi on 23/01/2023.
//

import SwiftUI

struct SearchView: View {
    @State var query = ""
    
    let names = (0..<30)
        .map { "Username \($0)" }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(names, id: \.self) { name in
                    NavigationLink {
                        ProfileView()
                    } label: {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                                .foregroundColor(Color.init(
                                    red: Double.random(in: 0..<1),
                                    green: Double.random(in: 0..<1),
                                    blue: Double.random(in: 0..<1)))
                            Text(name)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .searchable(text: $query)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
