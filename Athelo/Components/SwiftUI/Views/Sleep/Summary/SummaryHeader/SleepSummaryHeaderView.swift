//
//  SleepSummaryHeaderView.swift
//  Athelo
//
//  Created by Krzysztof Jabłoński on 26/07/2022.
//

import SwiftUI

final class SleepSummaryHeaderModel: ObservableObject {
    @Published var actionTitle: String?
    @Published var headerTitle: String?
    @Published var headerBody: String?
    
    func clearAll() {
        self.actionTitle = nil
        self.headerTitle = nil
        self.headerBody = nil
    }
}

struct SleepSummaryHeaderView: View {
    @EnvironmentObject var model: SleepSummaryHeaderModel
    private let linkTapAction: () -> Void
    
    init(linkTapAction: @escaping () -> Void) {
        self.linkTapAction = linkTapAction
    }
    
    private var shouldDisplayActionContents: Bool {
        model.actionTitle?.isEmpty == false
    }
    
    private var shouldDisplayHeaderContents: Bool {
        model.headerTitle?.isEmpty == false || model.headerBody?.isEmpty == false
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 16.0) {
            VStack(spacing: 4.0) {
                if shouldDisplayHeaderContents {
                    if let headerTitle = model.headerTitle {
                        StyledText(headerTitle,
                                   textStyle: .headline20,
                                   colorStyle: .gray,
                                   alignment: .leading)
                    }
                    
                    if let headerBody = model.headerBody {
                        StyledText(headerBody,
                                   textStyle: .headline24,
                                   colorStyle: .lightOlivaceous,
                                   alignment: .leading)
                    }
                }
                
                if shouldDisplayActionContents {
                    Button {
                        linkTapAction()
                    } label: {
                        StyledText(model.actionTitle ?? "",
                                   textStyle: .button,
                                   colorStyle: .lightOlivaceous,
                                   alignment: .leading,
                                   underlined: true)
                    }
                    .padding(.top, 12.0)
                }
            }
            
            Image("sleepingMoon")
        }
        .padding(16.0)
        .padding(.top, 8.0)
        .background(
            Rectangle().fill(Color(UIColor.withStyle(.background).cgColor)),
            alignment: .center
        )
        .cornerRadius(30.0)
        .styledShadow()
    }
}

struct SleepSummaryHeaderView_Previews: PreviewProvider {
    private static let model: SleepSummaryHeaderModel = {
        let model = SleepSummaryHeaderModel()
        
        model.actionTitle = "Read Article"
        model.headerTitle = "Ideal Hours for Sleep"
        model.headerBody = "8h 30m"
        
        return model
    }()
    
    static var previews: some View {
        SleepSummaryHeaderView(linkTapAction: { /* ... */ })
            .environmentObject(model)
            .padding()
    }
}
