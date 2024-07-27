//
//  Note+Model.swift
//  miami assistence
//
//  Created by Rodrigo Souza on 05/09/23.
//

import Foundation
import SwiftUI
import SwiftData

extension Note {
    enum BlockType: String, Equatable {
        case text, image, video, list, table, header, quote, link, embed
    }
    
    struct Block: Identifiable, Equatable {
        var id: UUID = UUID()
        var type: BlockType
        var content: String?
        var contentCache: NSAttributedString?
        var textAttributes: [TextAttribute]?
        var mediaAttributes: MediaBlockAttributes?
        var fileMetadata: FileMetadata?
        var children: [Block] = []
        var metadata: BlockMetadata
    }
    
    struct TextAttribute: Equatable {
        var range: NSRange
        var styles: [TextStyle]
    }

    enum TextStyle: Equatable {
        case bold
        case italic
        case underline
        case strikethrough
        case fontSize(Int)
        case fontName(String)
        case textColor(String)
        case backgroundColor(String)
        case link(URL)
    }

    struct MediaBlockAttributes: Equatable {
        var src: URL
        var storagePath: String?
        var altText: String?
        var width: Int?
        var height: Int?
        var caption: String?
        var mimeType: String?
        var accessLevel: AccessLevel
    }

    enum AccessLevel: Equatable {
        case `public`, restricted, `private`
    }

    struct FileMetadata: Equatable {
        var lastModified: Date = Date()
        var createdBy: String
        var version: String?
        var checksum: String?
        var tags: [String] = []
    }

    struct BlockMetadata: Equatable {
        var createdDate: Date = Date()
        var modifiedDate: Date = Date()
        var author: String
        var tags: [String] = []
    }
    
    struct DocumentModel: Identifiable, Equatable {
        var id: UUID = UUID()
        var blocks: Block
    }
}
