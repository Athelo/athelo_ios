//
//  ContentfulService.swift
//  Athelo
//
//  Created by RD Singh on 2023-10-27.
//

import Combine
import Foundation
import RichTextRenderer
import Contentful

public struct ContentfulService {
    //space id  = 74inuolao5zp
    //tokrn = "ErSYZQkgvZS_ay_yGO-g31thbchmG0Lxz4n_B6Ba1H8";
    private let client: Client
   
    public init() {
     
        client = Client(
            spaceId: "l655w91l0oq8",
            environmentId: "master",
            accessToken: "QuqNdE_HgvDiEm4N1qOWqTxqk9Zzf73YxKtL-gmH4rc",
            contentTypeClasses: [ContentfulNewsData.self]
        )
        
    }
    
    func getAllNews(completionBlock : @escaping (_ result: Result<Array<ContentfulNewsData>,Error>) -> Void) {
        let query = QueryOn<ContentfulNewsData>()

        client.fetchArray(of: ContentfulNewsData.self, matching: query) { (result: Result<HomogeneousArrayResponse<ContentfulNewsData>,Error>) in
          switch result {
          case .success(let entriesArrayResponse):
              completionBlock(Result.success(entriesArrayResponse.items))
          case .failure(let error):
            print("Oh no something went wrong: \(error)")
              completionBlock(Result.failure(error))
          }
        }
    }
}


final class ContentfulNewsData: EntryDecodable, FieldKeysQueryable, Identifiable, Hashable {
    
    static func == (lhs: ContentfulNewsData, rhs: ContentfulNewsData) -> Bool {
        return (lhs.id == rhs.id && lhs.image == rhs.image && lhs.title == rhs.title)
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    
    static let contentTypeId: String = "articleContentModel"
    
    // FlatResource members.
    let id: String
    let localeCode: String?
    let updatedAt: Date?
    let createdAt: Date?
    
    let title: String
    let body: RichTextDocument?
    var image: Asset?
    let shouldOpenInBrowser: Bool
    let browserUrl: String
    var bottomLogo: Asset?
    
    public required init(from decoder: Decoder) throws {
        let sys = try decoder.sys()
        
        id = sys.id
        localeCode = sys.locale
        updatedAt = sys.updatedAt
        createdAt = sys.createdAt
        
        let fields = try decoder.contentfulFieldsContainer(keyedBy: ContentfulNewsData.FieldKeys.self)
        
        self.title = try fields.decodeIfPresent(String.self, forKey: .title) ?? ""
        self.body = try fields.decodeIfPresent(RichTextDocument.self, forKey: .body)
//        self.image = try fields.decodeIfPresent(String.self, forKey: .articleImage) ?? ""
        
        self.shouldOpenInBrowser =  try fields.decodeIfPresent(Bool.self, forKey: .shouldOpenInBrowser) ?? false
        self.browserUrl = try fields.decodeIfPresent(String.self, forKey: .browserUrl) ?? ""
        
        try fields.resolveLink(forKey: .articleImage, decoder: decoder) { [weak self] image in
            self?.image = image as? Asset
        }
        try fields.resolveLink(forKey: .bottomLogo, decoder: decoder) { [weak self] image in
            self?.bottomLogo = image as? Asset
        }
    }
    
    // If your field names and your properties names differ, you can define the mapping in your `FieldKeys` enum.
    enum FieldKeys: String, CodingKey {
        case title
        case body
        case articleImage
        case shouldOpenInBrowser
        case browserUrl
        case bottomLogo
    }
    
}

extension ContentfulNewsData: ArticleCellDecorationData {
    var articleCellBody: String? {
        return if let body = body {
            RichTextDocumentRenderer(configuration: DefaultRendererConfiguration()).render(document: body).string
        } else {
            ""
        }
    }
    
    var articleCellPhoto: LoadableImageData? {
        guard let photo = image else {
            return nil
        }
        
        do {
            return try .url(photo.url())
        } catch {
            return nil
        }
    }
    
    var articleCellTitle: String? {
        title
    }
}
