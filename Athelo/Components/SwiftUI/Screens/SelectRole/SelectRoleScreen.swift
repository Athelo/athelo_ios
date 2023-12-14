//
//  SelectRoleView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 15/09/2022.
//

import SwiftUI

struct SelectRoleScreen: View {
    @State private var listItems: [RoleItemData] = [
        .init(role: .patient),
        .init(role: .caregiver)
    ]
    
    let onTapAction: (UserRole) -> ()
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                
                Image("wavesBackground")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            
            VStack(spacing: 40.0) {
                VStack(spacing: 8.0) {
                    StyledText(
                        "role.selection.header".localized(),
                        textStyle: .intro,
                        colorStyle: .purple623E61,
                        alignment: .center
                    )
                    
                    StyledText(
                        "role.selection.prompt".localized(),
                        textStyle: .intro,
                        colorStyle: .purple623E61,
                        alignment: .center
                    )
                }
                
                VStack(spacing: 24.0) {
                    ForEach(listItems) { item in
                        ListTileView(data: .init(
                            data: item,
                            displaysBackgroundWaves: true,
                            displaysNavigationChevron: true,
                            forceTitleLeadingOffset: true
                        ))
                        .onTapGesture {
                            onTapAction(item.role)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16.0)
            .padding(.top, 24.0)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

private extension SelectRoleScreen {
    struct RoleItemData: Hashable, Identifiable, ListTileDataProtocol {
        let role: UserRole
        
        var id: Int {
            role.rawValue
        }
        
        var listTileTitle: String {
            "role.prompt.select".localized(arguments: [role.roleDescription.lowercased()]).localized()
        }
        
        var listTileImage: LoadableImageData? {
            switch role {
            case .patient:
                return .image(.init(named: "personSolid")!)
            case .caregiver:
                return .image(.init(named: "handHeartSolid")!)
            }
        }
    }
}

struct SelectRoleScreen_Previews: PreviewProvider {
    static var previews: some View {
        SelectRoleScreen(onTapAction: { _ in /* ... */ })
    }
}
