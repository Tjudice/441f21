import SwiftUI
import GoogleSignIn

struct SigninView: View {
    @Binding var isPresented: Bool
    @Binding var isSignedin: Bool

    private let signinClient = GIDSignIn.sharedInstance
    
    struct SigninButton: UIViewRepresentable {
            func makeUIView(context: Context) -> GIDSignInButton {
                return GIDSignInButton()
            }
            
            func updateUIView(_ signinButton: GIDSignInButton, context: Context) {}
    }
    func backendSignin(_ token: String?) {
        Task {
            isSignedin = await ChattStore.shared.addUser(token)
            isPresented.toggle()
        }
    }
    var body: some View {
        SigninButton()
            .frame(width:100, height:50, alignment: Alignment.center)
            .task {
                            if let user = signinClient.currentUser {
                                let auth: GIDAuthentication? = await withCheckedContinuation { continuation in
                                    user.authentication.do { auth, error in
                                        continuation.resume(returning: error == nil ? auth : nil)
                                    }
                                }
                                backendSignin(auth?.idToken)
                            } else {
                                let user: GIDGoogleUser? = await withCheckedContinuation { continuation in
                                    signinClient.restorePreviousSignIn { user, error in
                                        continuation.resume(returning: error == nil ? user : nil)
                                    }
                                }
                                if let user = user {
                                    backendSignin(user.authentication.idToken)
                                }
                            }
                        }
            .onTapGesture {
                guard let rootVC = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.rootViewController else {
                    return
                }
                let signInConfig = GIDConfiguration.init(clientID: "751671678720-n3t27a1rml3mr9a7u9tdflbnac9n5e53.apps.googleusercontent.com")
                
                Task {
                    let user: GIDGoogleUser? = await withCheckedContinuation { continuation in
                        signinClient.signIn(with: signInConfig, presenting: rootVC) { user, error in
                            if error != nil {
                                print("signIn: \(error!.localizedDescription)")
                            }
                            continuation.resume(returning: error == nil ? user : nil)
                        }
                    }
                    backendSignin(user?.authentication.idToken)
                }
            }


    }
    

}
