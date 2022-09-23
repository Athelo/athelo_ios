import Foundation

public struct PasswordChangeRequest: APIRequest {
    let oldPassword: String
    let newPassword: String
    let newPasswordRepeated: String
    
    public init(oldPassword: String, newPassword: String, newPasswordRepeated: String) {
        self.oldPassword = oldPassword
        self.newPassword = newPassword
        self.newPasswordRepeated = newPasswordRepeated
    }
    
    public var parameters: [String : Any]? {
        ["old_password": oldPassword,
         "new_password1": newPassword,
         "new_password2": newPasswordRepeated]
    }
}
