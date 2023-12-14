//
//  SelectedWardView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 24/03/2023.
//

import SwiftUI

struct SelectedWardView: View {
    @ObservedObject var model: SelectedWardModel
    
    let onTapAction: () -> Void
    
    var body: some View {
        HStack(spacing: 0.0) {
            VStack(spacing: 4.0) {
                StyledText(
                    "Selected ward",
                    textStyle: .body,
                    colorStyle: .gray,
                    alignment: .leading
                )
                
                HStack(alignment: .center, spacing: 8.0) {
                    if let wardData = model.selectedWard {
                        StyledImageView(
                            imageData: wardData.avatarImage(in: CGSize(width: 36.0, height: 36.0))
                        )
                        .frame(width: 36.0, height: 36.0)
                        .roundedCorners(radius: 18.0)
                        
                        StyledText(
                            wardData.contactDisplayName ?? "Your Ward",
                            textStyle: .headline20,
                            colorStyle: .black,
                            extending: false
                        )
                    } else {
                        StyledText(
                            "No ward selected",
                            textStyle: .headline20,
                            colorStyle: .black,
                            extending: false
                        )
                    }
                    
                    Image("arrowDown")
                    
                    Spacer()
                }
                .onTapGesture {
                    onTapAction()
                }
            }
            
            Spacer()
        }

    }
}

struct SelectedWardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SelectedWardView(
                model: {
                    let model = SelectedWardModel()
                    model.updateWard(IdentityCommonProfileData.sample)
                    
                    return model
                }(),
                onTapAction: { /* ... */ }
            )
            
            SelectedWardView(
                model: SelectedWardModel(),
                onTapAction: { /* ... */ }
            )
        }
    }
}

private extension IdentityCommonProfileData {
    static var sample: IdentityCommonProfileData {
        IdentityCommonProfileData(id: 1, displayName: "User 1", imageURL: URL(string: "https://images.unsplash.com/photo-1512451590339-a3268f0402d9?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=320&q=80")!)
    }
    
    init(id: Int, displayName: String, imageURL: URL) {
        self.id = id
        self.photo = ImageData(
            id: 1,
            image: imageURL,
            image50px: imageURL,
            image100px: imageURL,
            image125px: imageURL,
            image250px: imageURL,
            image500px: imageURL,
            name: nil
        )
        
        self.profileFriendVisibilityOnly = nil
        self.displayName = displayName
    }
}
