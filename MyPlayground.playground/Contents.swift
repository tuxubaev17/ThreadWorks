import Foundation

public struct Chip {
    public enum ChipType: UInt32 {
        case small = 1
        case medium
        case big
    }
    
    public let chipType: ChipType
    
    public static func make() -> Chip {
        guard let chipType = Chip.ChipType(rawValue: UInt32(arc4random_uniform(3) + 1)) else {
            fatalError("Incorrect random value")
        }
        
        return Chip(chipType: chipType)
    }
    
    public func sodering() {
        let soderingTime = chipType.rawValue
        sleep(UInt32(soderingTime))
        print(soderingTime)
    }
}

var chipArray = [Chip]()
let condition = NSCondition()
var available = false


class GenerateThread: Thread {

    override func main() {
        for _ in 1...10 {
            condition.lock()
            chipArray.insert(Chip.make(), at: 0)
            print("I made")
            available = true
            condition.signal()
            condition.unlock()
            
            GenerateThread.sleep(forTimeInterval: 2)
        }
    }
}

class WorkThread: Thread {
    
    override func main() {
        for _ in 1...10 {
           while (!available) {
               condition.wait()
           }
            chipArray.removeFirst().sodering()
            
            if chipArray.count < 1 {
                available = false
            }
        }
    }
}


let generateThread = GenerateThread()
let workThread = WorkThread()

generateThread.start()
workThread.start()
