//
//  CPULoadWatcher.swift
//  
//
//  Created by Dorian Grolaux on 20/09/2022.
//

import Foundation
import Combine

/**
 A low-level helper that retrieves CPU & thread load.
 
 Most of the implementation were taken from various threads I could find online (with references hereafter). Some modifications were required to fit it into this project however.
 - Note: Base implementation [Credits VenoMKO](https://stackoverflow.com/a/6795612/1033581)
 - Note: `sysctl` usage [Credits Matt Gallagher](https://github.com/mattgallagher/CwlUtils/blob/master/Sources/CwlUtils/CwlSysctl.swift)
 - Note: `vm_deallocate` [Credits rsfinn](https://stackoverflow.com/a/48630296/1033581)
 */
class CPULoadWatcher: MetricProviderUseCase {
    
    // MARK: - Private
    
    private var cpuInfo: processor_info_array_t!
    private var prevCpuInfo: processor_info_array_t?
    private var numCpuInfo: mach_msg_type_number_t = 0
    private var numPrevCpuInfo: mach_msg_type_number_t = 0
    private var numCPUs: uint = 0
    private let CPUUsageLock: NSLock = NSLock()
    
    // MARK: - Internal
    
    internal init() {
        let mibKeys: [Int32] = [CTL_HW, HW_NCPU]
        // sysctl Swift usage credit Matt Gallagher
        mibKeys.withUnsafeBufferPointer() { mib in
            var sizeOfNumCPUs: size_t = MemoryLayout<uint>.size
            let status = sysctl(processor_info_array_t(mutating: mib.baseAddress), 2, &numCPUs, &sizeOfNumCPUs, nil, 0)
            if status != 0 {
                numCPUs = 1
            }
        }
    }
    
    // MARK: Protocol Conformance
    
    static let minValue: Float = 0.0
    static let maxValue: Float = 1.0
    
    func fetchMetric() throws -> Float {
        var loads: [Float] = []
        
        var numCPUsU: natural_t = 0
        let err: kern_return_t = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUsU, &cpuInfo, &numCpuInfo);
        if err == KERN_SUCCESS {
            CPUUsageLock.lock()
            
            for i in 0 ..< Int32(numCPUs) {
                var inUse: Int32
                var total: Int32
                if let prevCpuInfo = prevCpuInfo {
                    inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                    
                    + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                    
                    + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                    - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                    
                    total = inUse + (cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                                     - prevCpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)])
                } else {
                    inUse = cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_USER)]
                    + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_SYSTEM)]
                    + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_NICE)]
                    
                    total = inUse + cpuInfo[Int(CPU_STATE_MAX * i + CPU_STATE_IDLE)]
                }
                
                loads.append(Float(inUse) / Float(total))
            }
            CPUUsageLock.unlock()
            
            if let prevCpuInfo = prevCpuInfo {
                // vm_deallocate Swift usage credit rsfinn: https://stackoverflow.com/a/48630296/1033581
                let prevCpuInfoSize: size_t = MemoryLayout<integer_t>.stride * Int(numPrevCpuInfo)
                vm_deallocate(mach_task_self_, vm_address_t(bitPattern: prevCpuInfo), vm_size_t(prevCpuInfoSize))
            }
            
            prevCpuInfo = cpuInfo
            numPrevCpuInfo = numCpuInfo
            
            cpuInfo = nil
            numCpuInfo = 0
        } else {
            throw Error.kernelReturnError
        }
        return loads.reduce(Float(0), +) / Float(loads.count)
    }
}

extension CPULoadWatcher {
    enum Error: Swift.Error, CustomDebugStringConvertible {
        /// Something went wrong trying to access the host processor info
        case kernelReturnError
        
        var debugDescription: String {
            switch self {
            case .kernelReturnError:
                return "Something went wrong trying to access the host processor info"
            }
        }
    }
}
