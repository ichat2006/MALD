//
//  Client.swift
//
//
//  Created by Ishaan Chaturvedi
//

import Foundation

final class Client: GenericApi {

	let session: URLSession

	init(configuration: URLSessionConfiguration) {
		self.session = URLSession(configuration: configuration)
	}

	convenience init() {
		self.init(configuration: .default)
	}
}
