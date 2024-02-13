//
//  String + DateModify.swift
//  Athelo
//
//  Created by Devsto on 07/02/24.
//

import Foundation

extension String {
    func changeDateStringTo(Base baseFormate: String, Changeto convertFormate: String) -> String? {
        let tempDate = self.toDate(style:.custom(baseFormate))
        return tempDate?.toString(.custom(convertFormate))
    }
}
