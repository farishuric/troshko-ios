import Foundation
import OSLog

public enum DependencyScope {
    case singleton
    case transient
    case scoped
}

public enum DependencyLifecycle {
    case persistent
    case resettable
    case feature
}

public struct DependencyConfiguration {
    public let scope: DependencyScope
    public let lifecycle: DependencyLifecycle
    
    public init(scope: DependencyScope, lifecycle: DependencyLifecycle) {
        self.scope = scope
        self.lifecycle = lifecycle
    }
    
    public static let shared = DependencyConfiguration(scope: .singleton, lifecycle: .persistent)
    public static let transient = DependencyConfiguration(scope: .transient, lifecycle: .persistent)
    public static let userSession = DependencyConfiguration(scope: .singleton, lifecycle: .resettable)
    public static let featureScoped = DependencyConfiguration(scope: .scoped, lifecycle: .feature)
}

private struct DependencyRegistration {
    let instance: Any?
    let factory: (() -> Any)?
    let configuration: DependencyConfiguration
    
    init(instance: Any, configuration: DependencyConfiguration) {
        self.instance = instance
        self.factory = nil
        self.configuration = configuration
    }
    
    init(factory: @escaping () -> Any, configuration: DependencyConfiguration) {
        self.instance = nil
        self.factory = factory
        self.configuration = configuration
    }
}

public class DIContainer {
    public static let shared = DIContainer()
    private var registrations: [String: DependencyRegistration] = [:]
    private var scopedInstances: [String: [String: Any]] = [:]
    private let logger = Logger(subsystem: "com.di", category: "DIContainer")
    
    private init() {}

    public func register<Service, Implementation>(
        _ service: Implementation,
        as type: Service.Type,
        configuration: DependencyConfiguration = .shared
    ) {
        let key = String(describing: type)
        registrations[key] = DependencyRegistration(instance: service, configuration: configuration)
    }
    
    public func register<Service>(
        as type: Service.Type,
        configuration: DependencyConfiguration = .shared,
        factory: @escaping () -> Service
    ) {
        let key = String(describing: type)
        registrations[key] = DependencyRegistration(factory: factory, configuration: configuration)
    }
    
    public func registerIfNeeded<Service, Implementation>(
        _ service: @autoclosure () -> Implementation,
        as type: Service.Type,
        configuration: DependencyConfiguration = .shared
    ) {
        let key = String(describing: type)
        if registrations[key] == nil {
            registrations[key] = DependencyRegistration(instance: service(), configuration: configuration)
        }
    }
    
    public func isRegistered<Service>(_ type: Service.Type) -> Bool {
        let key = String(describing: type)
        return registrations[key] != nil
    }

    public func resolve<Service>(_ type: Service.Type, scope: String = "default") -> Service {
        let key = String(describing: type)
        guard let registration = registrations[key] else {
            fatalError("Dependency \(key) not registered.")
        }
        
        switch registration.configuration.scope {
        case .singleton:
            if let instance = registration.instance as? Service {
                return instance
            } else if let factory = registration.factory {
                fatalError("Singleton factory should create instance at registration time")
            }
            fatalError("Failed to resolve singleton \(key)")
            
        case .transient:
            guard let factory = registration.factory else {
                fatalError("Transient dependencies require a factory")
            }
            guard let instance = factory() as? Service else {
                fatalError("Factory failed to create instance of type \(key)")
            }
            return instance
            
        case .scoped:
            if let scopedInstance = scopedInstances[scope]?[key] as? Service {
                return scopedInstance
            }
            
            let instance: Service
            if let existingInstance = registration.instance as? Service {
                instance = existingInstance
            } else if let factory = registration.factory, let createdInstance = factory() as? Service {
                instance = createdInstance
            } else {
                fatalError("Failed to create scoped instance of \(key)")
            }
            
            if scopedInstances[scope] == nil {
                scopedInstances[scope] = [:]
            }
            scopedInstances[scope]?[key] = instance
            return instance
        }
    }
    
    public func reset(lifecycle: DependencyLifecycle) {
        let keysToRemove = registrations.filter { $0.value.configuration.lifecycle == lifecycle }.map { $0.key }
        keysToRemove.forEach { registrations.removeValue(forKey: $0) }
        
        if lifecycle == .feature {
            scopedInstances.removeAll()
        }
    }
    
    public func clearScope(_ scope: String) {
        scopedInstances.removeValue(forKey: scope)
    }
    
    public func reset() {
        registrations.removeAll()
        scopedInstances.removeAll()
    }
}

@propertyWrapper public struct Injected<T> {
    private var storage: T?
    private let container: DIContainer
    private let scope: String
    private let logOverrides: Bool
    
    public var wrappedValue: T {
        get {
            if let overridden = storage {
                if logOverrides {
                    #if DEBUG
                    Logger(subsystem: "com.di", category: "Injected").debug("Using manually injected value for \(String(describing: T.self))")
                    #endif
                }
                return overridden
            }
            
            return container.resolve(T.self, scope: scope)
        }
        set {
            if logOverrides {
                #if DEBUG
                Logger(subsystem: "com.di", category: "Injected").debug("Manually injecting value for \(String(describing: T.self))")
                #endif
            }
            storage = newValue
        }
    }
    
    public var projectedValue: InjectedValue<T> {
        InjectedValue(
            isOverridden: storage != nil,
            resolve: { container.resolve(T.self, scope: scope) }
        )
    }

    public init(
        container: DIContainer = .shared,
        scope: String = "default",
        logOverrides: Bool = false
    ) {
        self.container = container
        self.scope = scope
        self.logOverrides = logOverrides
        self.storage = nil
    }
}

public struct InjectedValue<T> {
    public let isOverridden: Bool
    private let resolve: () -> T
    
    internal init(isOverridden: Bool, resolve: @escaping () -> T) {
        self.isOverridden = isOverridden
        self.resolve = resolve
    }
    
    public func forceResolve() -> T {
        resolve()
    }
}

