//
//  File.swift
//  
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation

class MemoryLoadWatcher {
    func memoryFootprint() -> String {
        // The `TASK_VM_INFO_COUNT` and `TASK_VM_INFO_REV1_COUNT` macros are too
        // complex for the Swift C importer, so we have to define them ourselves.
        let TASK_VM_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<integer_t>.size)
        
        guard let offset = MemoryLayout.offset(of: \task_vm_info_data_t.min_address) else {
            return "memory: NA"
        }
        
        let TASK_VM_INFO_REV1_COUNT = mach_msg_type_number_t(offset / MemoryLayout<integer_t>.size)
        
        var info = task_vm_info_data_t()
        var count = TASK_VM_INFO_COUNT
        let kr = withUnsafeMutablePointer(to: &info) { infoPtr in
            infoPtr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), intPtr, &count)
            }
        }
        guard
            kr == KERN_SUCCESS,
            count >= TASK_VM_INFO_REV1_COUNT
        else { return "memory: NA" }
        
        let usedBytes = Float(info.phys_footprint)
        let usedBytesInt: UInt64 = UInt64(usedBytes)
        let usedMB = usedBytesInt / 1024 / 1024
        let usedMBAsString: String = "memory: \(usedMB) MB"
        return usedMBAsString
    }
}
