//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Eric Garlock on 2/16/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
	
	let container: NSPersistentContainer
	
	public init() {
		
		let bundle = Bundle(for: CoreDataFeedStore.self)
		let modelURL = bundle.url(forResource: "CoreDataFeedStore", withExtension: "momd")!
		let model = NSManagedObjectModel(contentsOf: modelURL)!
		
		let description = NSPersistentStoreDescription(url: URL(fileURLWithPath: "/dev/null"))
		
		let container = NSPersistentContainer(name: "CoreDataFeedStore", managedObjectModel: model)
		container.persistentStoreDescriptions = [description]
		
		container.loadPersistentStores { _, error in
			if let error = error {
				fatalError("\(error)")
			}
		}
		
		self.container = container
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		completion(nil)
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		completion(nil)
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
	
}


@objc(CoreDataFeedCache)
private class CoreDataFeedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: [CoreDataFeedImage]
}

@objc(CoreDataFeedImage)
private class CoreDataFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var image_description: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
}
