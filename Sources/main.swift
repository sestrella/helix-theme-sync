// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import Cocoa
import Foundation
import Logging

let logger = Logger(label: "com.sestrella.helix-theme-sync")

class ThemeChangedObserver {
	let center = DistributedNotificationCenter.default
	let fileManager = FileManager.default

	private var configThemesDir: String
	private var runtimeThemesDir: String
	private var theme: String

	private var centralObserver: NSObjectProtocol?
	private var workspaceObserver: NSObjectProtocol?

	init(configThemesDir: String, runtimeThemesDir: String, theme: String) {
		self.configThemesDir = configThemesDir
		self.runtimeThemesDir = runtimeThemesDir
		self.theme = theme
	}

	func add() {
		logger.info("Adding central observer...")
		centralObserver = center.addObserver(
			forName: Notification.Name("AppleInterfaceThemeChangedNotification"),
			object: nil,
			queue: .main
		) { _ in
			self.themeChanged()
		}

		logger.info("Adding workspace observer...")
		workspaceObserver = NSWorkspace.shared.notificationCenter.addObserver(
			forName: NSWorkspace.didWakeNotification,
			object: nil,
			queue: nil
		) { _ in
			self.themeChanged()
		}
	}

	func remove() {
		guard let observer = centralObserver else {
			return
		}

		logger.info("Removing central observer...")
		center.removeObserver(observer)

		guard let observer = workspaceObserver else {
			return
		}

		logger.info("Removing central observer...")
		NSWorkspace.shared.notificationCenter.removeObserver(observer)
	}

	private func themeChanged() {
		let isDark = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"

		if isDark {
			if symlinkTheme(suffix: "dark") {
				reloadConfig()
			}

			return
		}

		if symlinkTheme(suffix: "light") {
			reloadConfig()
		}
	}

	private func symlinkTheme(suffix: String) -> Bool {
		let destinationPath = "\(runtimeThemesDir)/\(theme)_\(suffix).toml"
		let themePath = "\(configThemesDir)/\(theme).toml"

		do {
			// Validate destination exists
			if !fileManager.fileExists(atPath: destinationPath) {
				logger.error("Destination theme file does not exist: \(destinationPath)")
				return false
			}

			logger.info("Creating themes directory at \(configThemesDir)")
			try fileManager.createDirectory(
				atPath: configThemesDir,
				withIntermediateDirectories: true
			)

			if fileManager.fileExists(atPath: themePath) {
				// If it's a symlink, check if it already points to the correct destination
				let currentDest = try fileManager.destinationOfSymbolicLink(atPath: themePath)
				if currentDest == destinationPath {
					logger.info("Symlink already up to date: \(themePath) -> \(destinationPath)")
					return false
				}

				logger.info("Removing existing theme file at \(themePath)")
				try fileManager.removeItem(atPath: themePath)
			}

			logger.info("Creating symlink from \(themePath) to \(destinationPath)")
			try fileManager.createSymbolicLink(
				atPath: themePath,
				withDestinationPath: destinationPath
			)
			return true
		} catch {
			logger.error("Error in symlinkTheme: \(error.localizedDescription)")
			return false
		}
	}

	private func reloadConfig() {
		let process = Process()
		process.launchPath = "/usr/bin/pgrep"
		process.arguments = ["hx"]

		let pipe = Pipe()
		process.standardOutput = pipe

		do {
			try process.run()
			process.waitUntilExit()

			let data = pipe.fileHandleForReading.readDataToEndOfFile()
			guard let output = String(data: data, encoding: .utf8) else {
				logger.error("Failed to read pgrep output")
				return
			}

			let pids = output.split(separator: "\n").compactMap { Int32($0) }
			if pids.isEmpty {
				logger.error("No running hx process found to signal")
				return
			}

			for pid in pids {
				if kill(pid, SIGUSR1) == 0 {
					logger.info("Sent SIGUSR1 to hx process with PID \(pid)")
				} else {
					logger.error("Failed to send SIGUSR1 to hx process with PID \(pid)")
				}
			}
		} catch {
			logger.error("Failed to reload hx config: \(error.localizedDescription)")
		}
	}
}

struct HelixThemeSync: ParsableCommand {
	static let configuration = CommandConfiguration(
		version: "0.1.0"
	)

	@Option(name: .shortAndLong, help: "Helix config themes directory")
	var configThemesDir: String = "~/.config/helix"

	@Option(name: .shortAndLong, help: "Helix runtime themes directory")
	var runtimeThemesDir: String

	@Option(name: .shortAndLong, help: "Theme name")
	var theme: String

	func run() throws {
		let observer = ThemeChangedObserver(
			configThemesDir: NSString(string: configThemesDir).expandingTildeInPath,
			runtimeThemesDir: NSString(string: runtimeThemesDir).expandingTildeInPath,
			theme: theme
		)
		observer.add()
		NSApplication.shared.run()
		observer.remove()
	}
}

// TODO: Rename this file and add @main annotation to HelixThemeSync.
HelixThemeSync.main()
