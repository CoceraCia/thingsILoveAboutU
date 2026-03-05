//
//  AsyncSemaphor.swift
//  ThingsILoveAboutU
//
//  Created by Miguel Cocera on 18/2/26.
//

actor AsyncSemaphore {
    private let maxPermits: Int
    private var available: Int
    private var waitQueue: [CheckedContinuation<Void, Never>] = []
    init(value: Int) {
        self.maxPermits = max(1, value)
        self.available = self.maxPermits
    }
    
    func acquire() async {
        if available > 0 {
            available -= 1
            return
        }
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            waitQueue.append(continuation)
        }
    }
    
    func release() {
        if let cont = waitQueue.first {
            waitQueue.removeFirst()
            cont.resume()
        } else {
            available = min(available + 1, maxPermits)
        }
    }
}
