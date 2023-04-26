extension Sequence {
    public func keyed<T: Hashable>(by value: (Element) -> T) -> [T: Element] {
        let withKeys = map { (value($0), $0) }
        return Dictionary(withKeys, uniquingKeysWith: { first, _ in first })
    }

    public func grouped<T: Hashable>(by grouping: (Element) -> T) -> [T: [Element]] {
        Dictionary(grouping: self, by: { grouping($0) })
    }
}
