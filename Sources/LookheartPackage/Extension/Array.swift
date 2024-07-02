import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
    
    subscript(safeIdx index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
