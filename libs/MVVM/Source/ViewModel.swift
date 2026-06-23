import Combine

public protocol ViewModel: ObservableObject {
    associatedtype State: ViewState
    associatedtype Event: ViewEvent
    associatedtype VMEvent: ViewModelEvent

    var state: State { get }
    var eventPublisher: AnyPublisher<VMEvent, Never> { get }

    func trigger(_ event: Event)
}

public protocol ViewState {}
public protocol ViewEvent {}
public protocol ViewModelEvent {}

public enum EmptyViewModelEvent: ViewModelEvent {
    case noEvent
}
