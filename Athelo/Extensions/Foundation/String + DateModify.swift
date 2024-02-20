//
//  String + DateModify.swift
//  Athelo
//
//  Created by Devsto on 07/02/24.
//

import Foundation

extension String {
    
    func convertStringToDate(_ formate: AtheloDateFormates) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "\(Locale.current.identifier)_POSIX")
        formatter.dateFormat = formate.rawValue
        guard let newDate = formatter.date(from: self) else {
            print("fail to pars String to date")
            return nil
        }
        return newDate
    }
    
    
    
    func changeDateStringTo(Base baseFormate: AtheloDateFormates, Changeto convertFormate: AtheloDateFormates) -> String? {
        
        let tempDate = self.convertStringToDate(baseFormate)
        return tempDate?.convertToString(formate: convertFormate)
        
//        let tempDate = self.toDate(style:.custom(baseFormate))
//        return tempDate?.toString(.custom(convertFormate))
    }
}



