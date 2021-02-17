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
	let context: NSManagedObjectContext
	
	public init(storeURL: URL) {
		
		let bundle = Bundle(for: CoreDataFeedStore.self)
		let modelURL = bundle.url(forResource: "CoreDataFeedStore", withExtension: "momd")!
		let model = NSManagedObjectModel(contentsOf: modelURL)!
		
		let description = NSPersistentStoreDescription(url: storeURL)
		
		let container = NSPersistentContainer(name: "CoreDataFeedStore", managedObjectModel: model)
		container.persistentStoreDescriptions = [description]
		
		container.loadPersistentStores { _, error in
			if let error = error {
				fatalError("\(error)")
			}
		}
		
		self.container = container
		self.context = container.newBackgroundContext()
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		let context = self.context
		context.perform {
			
			do {
				
				let request = CoreDataFeedCache.request
				
				if let cache = try context.fetch(request).first {
					context.delete(cache)
					try context.save()
				}
				
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		let context = self.context
		context.perform {
			
			do {
				
				let request = CoreDataFeedCache.request
				
				if let cache = try context.fetch(request).first {
					context.delete(cache)
				}
				
				let cache = CoreDataFeedCache(context: context)
				cache.timestamp = timestamp
				cache.feed = NSOrderedSet(array: feed.map { local in
					let core = CoreDataFeedImage(context: context)
					core.id = local.id
					core.image_description = local.description
					core.location = local.location
					core.url = local.url
					return core
				})
				
				try context.save()
				completion(nil)
			} catch {
				completion(error)
			}
		}
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let context = self.context
		context.perform {
			
			do {
				let request = CoreDataFeedCache.request
				
				if let cache = try context.fetch(request).first {
					completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
				} else {
					completion(.empty)
				}
			} catch {
				completion(.failure(error))
			}
		}
	}
	
}

private extension CoreDataFeedCache {
	static var request: NSFetchRequest<CoreDataFeedCache> {
		let request = NSFetchRequest<CoreDataFeedCache>(entityName: "CoreDataFeedCache")
		request.returnsObjectsAsFaults = false
		return request
	}
	
	var localFeed: [LocalFeedImage] {
		return feed.compactMap { ($0 as? CoreDataFeedImage)?.localImage }
	}
}
private extension CoreDataFeedImage {
	var localImage: LocalFeedImage {
		return LocalFeedImage(id: id, description: image_description, location: location, url: url)
	}
}

@objc(CoreDataFeedCache)
private class CoreDataFeedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
}

@objc(CoreDataFeedImage)
private class CoreDataFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var image_description: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
}
