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
            print(url)
        } catch {
            throw DataPersistenceError.savingError(error)
        }
    }
    
    public func update(_ oldItem: ImageObject, _ newItem: ImageObject) -> Bool {
    if let index = images.firstIndex(of: oldItem) {
        let result = update(newItem, index)
        return result
    }
        return false
    }
    
    public func update(_ item: ImageObject, _ index: Int) -> Bool {
        images[index] = item
        do {
            try save()
            return true
        } catch {
            return false
        }
    }
    
    public func reorderImages(image: [ImageObject]) {
        self.images = image
        try? save()
    }
    
    public func createItem(event: ImageObject) throws {
        print(images.count)
        do {
            images = try loadImages()
        } catch {
            throw error
        }
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
