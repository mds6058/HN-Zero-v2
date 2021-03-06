//
//  Comment.swift
//  Hacker News Zero
//
//  Created by Matt Stanford on 3/9/18.
//  Copyright © 2018 locacha. All rights reserved.
//

import Foundation

struct Comment: Codable, CommentContainable, HackerNewsItemType {
    let id: Int
    let parentId: Int
    let author: String?
    let text: String?
    let childCommentIds: [Int]?
    let isDead: Bool?
    let time: Date
    let deleted: Bool?

    //Not part of the JSON
    var childComments: [Comment]?

    private enum CodingKeys: String, CodingKey {
        case id
        case parentId = "parent"
        case author = "by"
        case text
        case childCommentIds = "kids"
        case isDead = "dead"
        case childComments
        case time
        case deleted
    }

    var isDeleted: Bool {
        return deleted ?? false
    }

    var hasChildComments: Bool {
        if let childIds = childCommentIds {
            return childIds.count > 0
        } else {
            return false
        }
    }

    static func decodeComment(from jsonData: Data) -> Comment? {
        let decoder = JSONDecoder()

        decoder.dateDecodingStrategy = .secondsSince1970
        let comment = try? decoder.decode(Comment.self, from: jsonData)

        return comment
    }

    static func createEmptyComment() -> Comment {
        return Comment(id: 0,
                       parentId: 0,
                       author: nil,
                       text: nil,
                       childCommentIds: nil,
                       isDead: nil,
                       time: Date(),
                       deleted: true,
                       childComments: nil)
    }
}
