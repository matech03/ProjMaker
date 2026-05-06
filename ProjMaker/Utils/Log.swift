//
//  LogHelper.swift
//  TVChromeCast
//
//  Created by Lý on 15/4/26.
//

import Foundation
import OSLog

enum Log {
	private static let subsystem = Bundle.main.bundleIdentifier ?? "App"

	static func debug(
		_ message: String,
		category: String = "general",
		fileID: String = #fileID,
		line: Int = #line
	) {
		let source = makeSourcePrefix(fileID: fileID, line: line)
		logger(category).debug("\(source, privacy: .public)\(message, privacy: .public)")
	}

	static func info(
		_ message: String,
		category: String = "general",
		fileID: String = #fileID,
		line: Int = #line
	) {
		let source = makeSourcePrefix(fileID: fileID, line: line)
		logger(category).info("\(source, privacy: .public)\(message, privacy: .public)")
	}

	static func error(
		_ message: String,
		category: String = "general",
		fileID: String = #fileID,
		line: Int = #line
	) {
		let source = makeSourcePrefix(fileID: fileID, line: line)
		logger(category).error("\(source, privacy: .public)\(message, privacy: .public)")
	}

	private static func logger(_ category: String) -> Logger {
		return Logger(subsystem: subsystem, category: category)
	}
	
	private static func makeSourcePrefix(fileID: String, line: Int) -> String {
		let fileName = fileID.split(separator: "/").last ?? Substring(fileID)
		return "\(fileName)[\(line)]: "
	}
}
