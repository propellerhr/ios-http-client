# HttpClient Swift Package

## Instalation
### SPM
TBD



## Usage

#### 1. Create a HttpClientConfiguration 
```swift
extension HttpClientConfiguration {
    static var myAppDev: HttpClientConfiguration {
        HttpClientConfiguration(baseURL: URL(string: "https://jsonplaceholder.typicode.com")!)
    }
}

```
#### 2. Initialize the HttpClient
Initialize the HttpClient before using it by executing:

```swift
HttpClient.initialize(configuration: .myAppDev)
```

#### 3. Create a Request 
```swift
class ToDoRequest: HttpRequestInterface {
    typealias Body = EmptyHttpRequestBody
    var path: String = "/todos"
    var method: HttpMethod = .get
}
```

#### 4. Create a Response object
```swift
struct ToDo: Codable {
    var userId: Int
    var title: String
    var completed: Bool
}
```

#### 5. Executing requests
```swift
import RxSwift

let http = HttpClient.shared
let disposeBag = DisposeBag()

func fetchTodos() -> Single<[ToDo]> {
    HttpClient.shared.perform(request: ToDoRequest())
}

func yourMethod() {
  fetchTodo()
    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
    .observe(on: MainScheduler.instance)
    .subscribe( { observer in
        switch observer {
        case .success(let todos):
            print("Fetched todos: \(model)")

        case .failure(let error):
            print("Whoops, something went wrong: \(error)")
        }
    })
    .disposed(by: disposeBag)
}

```
