import Foundation

protocol FlightService {
    func fetchFlights() async throws -> [Flight]
}

final class DefaultFlightService: FlightService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchFlights() async throws -> [Flight] {
        let endpoint = Endpoint(
            path: "api/flights",
            method: .get,
            requiresAuth: true
        )

        return try await apiClient.request(
            endpoint: endpoint,
            responseType: [Flight].self
        )
    }
}
