//
//  ContentView.swift
//  swiftUIChatter
//
//  Created by Trevor Judice on 11/10/21.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var store = ChattStore.shared
    @State private var toSignin = false
    @State private var isSignedin = false
    var body: some View {
        NavigationView {
                    List {
                        // need to put rows in a ForEach for listRowBackground color to take
                        ForEach(store.chatts.indices, id: \.self) {
                            ChattListRow(chatt: store.chatts[$0])
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color(($0 % 2 == 0) ? .systemGray5 : .systemGray6))
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await store.getChatts()
                    }
                    .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .principal) {
                                        Text("Chatter")
                                    }
                                    ToolbarItem(placement:.navigationBarTrailing) {
                                        Button(action: {
                                            if ChatterID.shared.expiration == Date(timeIntervalSince1970: 0.0) { // upon first launch
                                                        ChatterID.shared.open()
                                                    }
                                                                if let _ = ChatterID.shared.id {
                                                                    isSignedin.toggle()
                                                                } else {
                                                                    // chatterID is non-existent or expired
                                                                    toSignin.toggle()
                                                                }
                                                            }) {
                                                                Image(systemName: "square.and.pencil")
                                                            }
                                                            .sheet(isPresented: $toSignin) {
                                                                SigninView(isPresented: $toSignin, isSignedin: $isSignedin)
                                                            }
                                                            .sheet(isPresented: $isSignedin) {
                                                                PostView(isPresented: $isSignedin)
                                                            }
                                                        }
                                    }
                }
        .task {
                        await store.getChatts()
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
