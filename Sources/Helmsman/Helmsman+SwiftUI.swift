import SwiftUI

struct RouteEnvironmentKey: EnvironmentKey {
    static var defaultValue: ActivatedRoute = .root
}

public extension EnvironmentValues {
    internal(set) var route: ActivatedRoute {
        get { self[RouteEnvironmentKey.self] }
        set { self[RouteEnvironmentKey.self] = newValue }
    }
}

public struct RouteableNavigationLink<Content: View>: View {
    @EnvironmentObject private var router: Router
    
    @Environment(\.route) private var route: ActivatedRoute
    
    private let path: String
    private let destination: Content
    
    public init(_ path: String, @ViewBuilder destination: () -> Content) {
        self.path = path
        self.destination = destination()
    }
    
    private var isActive: Binding<Bool> {
        Binding(
            get: { route.matches(path: path) },
            set: { isActive in
                if route.matches(path: path) && route.matches(route: router.route) && !isActive {
                    router.pop()
                }
            }
        )
    }
    
    public var body: some View {
        NavigationLink(isActive: isActive) {
            destination
                .environment(\.route, route.nested())
                .environmentObject(router)
        } label: { EmptyView() }
            .isDetailLink(false)
    }
}

public struct RouterView<Content: View>: View {
    @StateObject private var router = Router()
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        content
            .environmentObject(router)
    }
}

public struct StaticRouterView<Content: View>: View {
    @ObservedObject private var router: Router
    
    private let content: Content
    
    public init(router: Router, @ViewBuilder content: () -> Content) {
        self._router = ObservedObject(initialValue: router)
        self.content = content()
    }
    
    public var body: some View {
        content
            .environmentObject(router)
    }
}

public struct RouteableNavigationView<Content: View>: View {
    @EnvironmentObject private var router: Router
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                content
            }
            .introspectNavigationController { navigationController in
                router.navigationController = navigationController
            }
        }
        .navigationViewStyle(.stack)
        .environment(\.route, router.route.nested())
        .environmentObject(router)
    }
}
