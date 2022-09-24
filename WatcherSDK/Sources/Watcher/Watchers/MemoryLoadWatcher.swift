//
//  MemoryLoadWatcher.swift
//  
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation

/**
 A low-level helper that retrieves memory load.
 
 Most of the implementation were taken from various threads I could find online (with references hereafter). Some modifications were required to fit it into this project however.
 - Note: Base implementation [Credits VenoMKO](https://stackoverflow.com/a/6795612/1033581)
 - Note: `sysctl` usage [Credits Matt Gallagher](https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlSysctl.swift)
 - Note: `vm_deallocate` [Credits rsfinn](https://stackoverflow.com/a/48630296/1033581)
 */
class MemoryLoadWatcher: MetricProviderUseCase {
    
    static let minValue: Float = 0
    static var maxValue: Float = {
        Float(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024
    }()
    
    func fetchMetric() throws -> Float {
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        guard let offset = MemoryLayout.offset(of: \task_vm_info_data_t.min_address) else {
            throw Error.invalidOffset
        }
        
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(offset / MemoryLayout<integer_t>.size)
        
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard kr == KERN_SUCCESS,
              count >= TASK_VM_INFO_REV1_COUNT else {
            throw Error.kernelReturnError
        }
        
        let usedBytes = Float(info.phys_footprint)
        let usedBytesInt: UInt64 = UInt64(usedBytes)
        let usedMB = usedBytesInt / 1024 / 1024
        return Float(usedMB)
    }
}

extension MemoryLoadWatcher {
    enum Error: Swift.Error {
        case invalidOffset
        case kernelReturnError
    }
}
