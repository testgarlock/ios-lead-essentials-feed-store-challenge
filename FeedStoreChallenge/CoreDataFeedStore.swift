//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Eric Garlock on 2/16/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
	
	public init() {}
	
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
