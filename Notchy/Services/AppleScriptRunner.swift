import AppKit

enum AppleScriptRunner {
    @discardableResult
    static func run(_ source: String) -> NSAppleEventDescriptor? {
        dispatchPrecondition(condition: .notOnQueue(.main))
        var errorInfo: NSDictionary?
        guard let script = NSAppleScript(source: source) else { return nil }
        let result = script.executeAndReturnError(&errorInfo)
        if errorInfo != nil {
            return nil
        }
        return result
    }

    static func runString(_ source: String) -> String? {
        guard let descriptor = run(source) else { return nil }
        return descriptor.stringValue
    }
}
