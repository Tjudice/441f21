//
//  PostView.swift
//  swiftChatter
//
//  Created by Trevor Judice on 10/11/21.
//

import UIKit

class PostView: UIView {
    let usernameLabel = UILabel(useMask: false, text: "tjudice")
    let messageTextView = UITextView(useMask: false, text: "Some sample short text")
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.backgroundColor = .systemBackground
        
        addSubview(usernameLabel)
        addSubview(messageTextView)

        let lmg = layoutMarginsGuide
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: lmg.topAnchor, constant: 20),
            usernameLabel.centerXAnchor.constraint(equalTo: lmg.centerXAnchor),

            messageTextView.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 20),
            messageTextView.leadingAnchor.constraint(equalTo: lmg.leadingAnchor),
            messageTextView.widthAnchor.constraint(equalTo: lmg.widthAnchor),
            
            bottomAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 10)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) view deserialization not supported")
    }
}
