# My Projects

## PokeDex

### HLD UML Diagram
[PokeDex HLD UML Diagram](https://drive.google.com/file/d/1rj64vxYIehiInN44wptd7_VTRQUSObk5/view?usp=sharing)

### Features
1. Implemented pagination for the vertically scrolling All Pokémons page, storing downloaded images and detailed information.
2. Implemented search functionality on the All Pokémons page.
3. Implemented pagination for the horizontally scrolling Pokémon Detail Page, along with zoom in and zoom out animation effects.
4. Implemented favorite functionality on the Pokémon Detail Page, storing this information.
5. Only used SnapKit as the third-party library.
6. Utilized MVVM-C and Clean Architecture as the project structure.
7. Used my previously packaged Swift Package for Network Module and Store Module.
8. To view the source code, please refer to `gogolook/pre-test`.

## RHNetworkModule

### HLD UML Diagram
[RHNetworkModule HLD UML Diagram](https://drive.google.com/file/d/1XZIxtJpFj8Nz6CUw0lM_iOyMoprn3QmU/view?usp=sharing)

### GitHub Repository
[RHNetworkModule GitHub Repository](https://github.com/HsinChungHan/RHNetwork)

### Features
- Implement `RequestType` to build the `URLRequest`
- Use `HTTPURLSession` to implement the `HTTPClient`
- Use `URLProtocol` to intercept all requests, facilitating the stubbing of responses for unit tests, and the coverage is almost 70%
- Also implement the end-to-end tests

## RHCacheStoreModule

### HLD UML Diagram
[RHCacheStoreModule HLD UML Diagram](https://drive.google.com/file/d/1NaNG4Wfvdl3L-_dPzuK7_0radgprjxYG/view?usp=sharing)

### GitHub Repository
[RHCacheStoreModule GitHub Repository](https://github.com/HsinChungHan/RHCacheStore)

### Features
- Use `FileManager` to store the data under concurrency environment
- Implement the expiry store
- Implement the unit tests
