import SwiftUI

struct PostView: View {
    let username = "tjudice"
    @State var message = "Some short sample text."
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Text(username)
                    .padding(.top, 30.0)
                TextEditor(text: $message)
                    .padding(EdgeInsets(top: 10, leading: 18, bottom: 0, trailing: 4))
                Spacer()
            }.navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Post")
                    }
                    ToolbarItem(placement:.navigationBarTrailing) {
                        Button(action: {
                            if let _ = ChatterID.shared.id {
                                                        Task {
                                                            await ChattStore.shared.postChatt(Chatt(username: username, message: message))
                                                            // we don't cancel Task in this lab
                                                            await ChattStore.shared.getChatts()
                                                        }
                                                    } else {
                                                        print("Error signing in. Please try again.")
                                                    }

                            isPresented.toggle()
                        }) {
                            Image(systemName: "paperplane")
                        }
                    }
                }
        }
    }
}
