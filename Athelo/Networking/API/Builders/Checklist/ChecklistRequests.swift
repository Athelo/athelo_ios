import Combine
import Foundation

public extension AtheloAPI {
    enum Checklist {
        private typealias Builder = ChecklistRequestBuilder
        
        public static func createChecklist<T: Decodable>(request: ChecklistCreateChecklistRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.createChecklist(request: request)).eraseToAnyPublisher()
        }
        
        public static func details<T: Decodable>(request: ChecklistDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.details(request: request)).eraseToAnyPublisher()
        }

        public static func list<T: Decodable>() -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.list).eraseToAnyPublisher()
        }

        public static func itemDetails<T: Decodable>(request: ChecklistItemDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.itemDetails(request: request)).eraseToAnyPublisher()
        }

        public static func templateDetails<T: Decodable>(request: ChecklistTemplateDetailsRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.templateDetails(request: request)).eraseToAnyPublisher()
        }
        
        public static func templateList<T: Decodable>(request: ChecklistTemplateListRequest) -> AnyPublisher<ListResponseData<T>, APIError> {
            APIService().request(with: Builder.templateList(request: request)).eraseToAnyPublisher()
        }
        
        public static func updateItem<T: Decodable>(request: ChecklistUpdateItemRequest) -> AnyPublisher<T, APIError> {
            APIService().request(with: Builder.updateItem(request: request)).eraseToAnyPublisher()
        }
    }
}
