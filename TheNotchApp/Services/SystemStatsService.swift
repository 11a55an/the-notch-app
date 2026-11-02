import Foundation
import Darwin

@MainActor
final class SystemStatsService: ObservableObject {
    @Published private(set) var cpuUsage: Double = 0
    @Published private(set) var memoryUsedFraction: Double = 0
    @Published private(set) var memoryUsedGB: Double = 0
    @Published private(set) var memoryTotalGB: Double = 0

    private var timer: Timer?
    private var previousCPUTicks: host_cpu_load_info?

    init() {
        memoryTotalGB = Double(ProcessInfo.processInfo.physicalMemory) / 1_073_741_824
    }

    func startPolling() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
    }

    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }

    func refresh() {
        if let usage = readCPUUsage() {
            cpuUsage = usage
        }
        if let (usedFraction, usedGB) = readMemoryUsage() {
            memoryUsedFraction = usedFraction
            memoryUsedGB = usedGB
        }
    }

    private func readCPUUsage() -> Double? {
        var loadInfo = host_cpu_load_info()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &loadInfo) { pointer -> kern_return_t in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPointer in
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, intPointer, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }

        defer { previousCPUTicks = loadInfo }
        guard let previous = previousCPUTicks else { return nil }

        let userDelta = Double(loadInfo.cpu_ticks.0 - previous.cpu_ticks.0)
        let systemDelta = Double(loadInfo.cpu_ticks.1 - previous.cpu_ticks.1)
        let idleDelta = Double(loadInfo.cpu_ticks.2 - previous.cpu_ticks.2)
        let niceDelta = Double(loadInfo.cpu_ticks.3 - previous.cpu_ticks.3)
        let totalDelta = userDelta + systemDelta + idleDelta + niceDelta
        guard totalDelta > 0 else { return nil }

        return (userDelta + systemDelta + niceDelta) / totalDelta
    }

    private func readMemoryUsage() -> (fraction: Double, usedGB: Double)? {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &stats) { pointer -> kern_return_t in
            pointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPointer in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, intPointer, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }

        var pageSize: vm_size_t = 0
        guard host_page_size(mach_host_self(), &pageSize) == KERN_SUCCESS else { return nil }

        let used = Double(stats.active_count + stats.wire_count + stats.compressor_page_count) * Double(pageSize)
        let total = Double(ProcessInfo.processInfo.physicalMemory)
        let usedGB = used / 1_073_741_824
        return (used / total, usedGB)
    }
}
