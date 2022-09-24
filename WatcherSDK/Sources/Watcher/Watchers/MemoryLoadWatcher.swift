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
 - note: Total System Memory Usage Implementation [Credits @Fangming](https://stackoverflow.com/a/44742639/3929910)
 - note: App Memory Usage Implementation [Credits mAc](https://stackoverflow.com/a/64893753/3929910)
 */
class MemoryLoadWatcher: MetricProviderUseCase {
    
    static let minValue: Float = 0
    static var maxValue: Float = {
        Float(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024
    }()
    
    func fetchMetric() throws -> Float {
        // Uncomment either one
        // try appUsage()
        try totalSystemUsage()
    }
    
    func appUsage() throws -> Float {
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
    
    func totalSystemUsage() throws -> Float {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else {
            throw Error.kernelReturnError
        }
        
        return Float(info.resident_size) / 1024 / 1024
    }
}

extension MemoryLoadWatcher {
    enum Error: Swift.Error {
        case invalidOffset
        case kernelReturnError
    }
}
