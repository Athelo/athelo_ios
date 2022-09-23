import Foundation

enum ChecklistRequestBuilder: APIBuilderProtocol {
    case createChecklist(request: ChecklistCreateChecklistRequest)
    case details(request: ChecklistDetailsRequest)
    case itemDetails(request: ChecklistItemDetailsRequest)
    case list
    case templateDetails(request: ChecklistTemplateDetailsRequest)
    case templateList(request: ChecklistTemplateListRequest)
    case updateItem(request: ChecklistUpdateItemRequest)

    var headers: [String : String]? {
        switch self {
        case .createChecklist, .details, .itemDetails, .list, .templateDetails, .templateList, .updateItem:
            return nil
        }
    }

    var method: APIMethod {
        switch self {
        case .createChecklist:
            return .post
        case .details, .itemDetails, .list, .templateDetails, .templateList:
            return .get
        case .updateItem:
            return .patch
        }
    }

    var parameters: [String : Any]? {
        switch self {
        case .list:
            return nil
        case .createChecklist(let request as APIRequest),
             .details(let request as APIRequest),
             .itemDetails(let request as APIRequest),
             .templateDetails(let request as APIRequest),
             .templateList(let request as APIRequest),
             .updateItem(let request as APIRequest):
            return request.parameters
        }
    }

    var path: String {
        switch self {
        case .createChecklist, .list:
            return "/checklists/user-checklists/"
        case .details(let request):
            return "/checklists/user-checklists/\(request.checklistID)/"
        case .itemDetails(let request):
            return "/checklists/user-checklist-items/\(request.itemID)/"
        case .templateDetails(let request):
            return "/checklists/checklist-templates/\(request.checklistTemplateID)"
        case .templateList(let request):
            var path = "/checklists/checklist-templates/?"
            
            if let isStarted = request.isStarted {
                path += "&is_started=\(isStarted)"
            }
            
            return path
        case .updateItem(let request):
            return "/checklists/user-checklist-items/\(request.id)/"
        }
    }
}
