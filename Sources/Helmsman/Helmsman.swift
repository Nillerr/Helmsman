import Combine
import Foundation

public struct RouteParameterKey<Value> {
    public let key: String
    
    public init(_ key: String) {
        self.key = key
    }
}

public struct RouteParameters {
    internal let values: [String : Any]
    
    public init() {
        self.values = [:]
    }
    
    private init(values: [String : Any]) {
        self.values = values
    }
    
    public func adding<Value>(_ value: Value, forKey key: RouteParameterKey<Value>) -> RouteParameters {
        RouteParameters(values: values.merging([key.key : value]) { a, b in b })
    }
}

public struct RouteSegment {
    public let path: String
    public let parameters: RouteParameters
    
    public init(_ path: String, parameters: RouteParameters = .init()) {
        self.path = path
        self.parameters = parameters
    }
    
    public func adding<Value>(_ value: Value, forKey key: RouteParameterKey<Value>) -> RouteSegment {
        RouteSegment(path, parameters: parameters.adding(value, forKey: key))
    }
}

public typealias RouteSegments = [RouteSegment]

internal extension Collection {
    subscript (optional index: Index) -> Element? {
        get { indices.contains(index) ? self[index] : nil }
    }
}

public struct ActivatedRoute {
    public static let root = ActivatedRoute(segments: [])
    
    internal let level: Int
    
    public let segments: RouteSegments
    
    public init(segments: RouteSegments) {
        self.level = -1
        self.segments = segments
    }
    
    private init(level: Int, segments: RouteSegments) {
        self.level = level
        self.segments = segments
    }
    
    private var path: [String] {
        segments.map { segment in segment.path }
    }
    
    public subscript <Value> (key: RouteParameterKey<Value>) -> Value {
        get { segments[level - 1].parameters.values[key.key] as! Value }
    }
    
    internal func nested() -> ActivatedRoute {
        ActivatedRoute(level: level + 1, segments: segments)
    }
    
    internal func matches(path: [String]) -> Bool {
        guard level > -1 else { return false }
        
        let matchPath = Array(
            segments
                .map { segment in segment.path }
                .suffix(from: level)
                .prefix(path.count)
        )
        
        return matchPath == path
    }
    
    internal func matches(path: String) -> Bool {
        self.path[optional: level] == path
    }
    
    /**
     Checks whether the full path of the route matches the full path of the route.
     */
    internal func matches(route: ActivatedRoute) -> Bool {
        path == route.path
    }
}

import Introspect
import UIKit

public class Router: ObservableObject {
    @Published private(set) var route: ActivatedRoute = .root
    
    public func activate(_ segments: RouteSegments) {
        if segments.count - route.segments.count - 1 > 0 {
            activate(partial: segments, through: route.segments.count)
        } else {
            self.route = ActivatedRoute(segments: segments)
        }
    }
    
    private func activate(partial segments: RouteSegments, through position: Int) {
        self.route = ActivatedRoute(segments: Array(segments.prefix(through: position)))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(550)) {
            self.activate(segments)
        }
    }
    
    public func pop() {
        let segments = Array(self.route.segments.dropLast())
        self.route = ActivatedRoute(segments: segments)
    }
    
    public func reset() {
        self.route = .root
    }
}
