# Helmsman

Routing using `NavigationView` in SwiftUI made easy.

## Getting Started

```swift
import Helmsman

extension RouteParameterKey {
    static var id: RouteParameterKey<String> {
        RouteParameterKey("id")
    }
}

extension RouteSegments {
    static func tasks() -> RouteSegments {
        [RouteSegment("tasks")]
    }
    
    static func task(id: String) -> RouteSegments {
        .tasks() + [RouteSegment("task").adding(id, forKey: .id)]
    }
}

struct ContentView: View {
    var body: some View {
        RouteableLoginView()
    
        ApplicationRoutesView()
    }
}

struct RouteableLoginView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        LoginView(login: { router.activate(.tasks()) })
    }
}

struct ApplicationRoutesView: View {
    var body: some View {
        RouteableNavigationLink("tasks") {
            RouteableTasksView()
            
            RouteableNavigationLink("task") {
                RouteableTaskView()
            }
        }
    }
}

struct RouteableTasksView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        TasksView(
            showTask: { id in router.activate(.task(id: id)) },
            logout: { router.reset() }
        )
    }
}

struct RouteableTaskView: View {
    @EnvironmentObject var router: Router
    
    var body: some View {
        TaskView(dismiss: { router.pop() })
    }
}
```
