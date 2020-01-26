//
//  PersistanceHelper.swift
//  PhotoJournalApp
//
//  Created by Brendon Cecilio on 1/23/20.
//  Copyright © 2020 Brendon Cecilio. All rights reserved.
//

import Foundation

enum DataPersistenceError: Error {
    case savingError(Error)
    case fileDoesNotExist(String)
    case noData
    case decodingError(Error)
    case deletingError(Error)
}

class PersistenceHelper {
    
    
    private var images = [ImageObject]()
    
    private var filename: String
    
    init(filename: String) {
        self.filename = filename
    }
    
    private func save() throws {
        let url = FileManager.pathToDocumentsDirectory(with: filename)
        do {
            let data = try PropertyListEncoder().encode(images)
            try data.write(to: url, options: .atomic)
        } catch {
            throw DataPersistenceError.savingError(error)
        }
    }
    
    
    public func reorderImages(image: [ImageObject]) {
        self.images = image
        try? save()
    }
    
    public func createItem(event: ImageObject) throws {
        images.append(event)
        
        do {
            try save()
        } catch {
            throw DataPersistenceError.savingError(error)
        }
    }
    
    public func loadImages() throws -> [ImageObject] {
        let url = FileManager.pathToDocumentsDirectory(with: filename)
        
        if FileManager.default.fileExists(atPath: url.path) {
            if let data = FileManager.default.contents(atPath: url.path) {
                do {
                    images = try PropertyListDecoder().decode([ImageObject].self, from: data)
                } catch {
                    throw DataPersistenceError.decodingError(error)
                }
            } else {
                throw DataPersistenceError.noData
            }
        }
        else {
            throw DataPersistenceError.fileDoesNotExist(filename)
        }
        return images
    }
    
    public func delete(item index: Int) throws {
        images.remove(at: index)
        
        do {
            try save()
        } catch {
            throw DataPersistenceError.deletingError(error)
        }
    }
}
