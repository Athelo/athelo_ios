import Foundation

/* Known report types:
     [
         1,
         "INDECENT_TEXT"
     ],
     [
         2,
         "INCORRECT_INFORMATION"
     ],
     [
         3,
         "OTHER"
     ]
 */

public struct ChatReportMessageRequest: APIRequest {
    let chatRoomID: String
    let messageTimestampID: Int64
    let reportTypeID: Int
    let reportMessage: String?

    public init(chatRoomID: String, messageTimestampID: Int64, reportTypeID: Int, message: String? = nil) {
        self.chatRoomID = chatRoomID
        self.messageTimestampID = messageTimestampID
        self.reportTypeID = reportTypeID
        self.reportMessage = message
    }
    
    public var parameters: [String : Any]? {
        var parameters: [String: Any] = [:]

        parameters["chat_room_identifier"] = chatRoomID
        parameters["message_timestamp_identifier"] = messageTimestampID
        parameters["report_type"] = reportTypeID
        
        if let message = reportMessage, !message.isEmpty {
            parameters["message"] = message
        }

        return parameters
    }
}
