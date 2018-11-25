struct Location: Codable {
	let consolidatedWeather: [ConsolidatedWeather]
	let time: String
	let title: String
	let woeid: Int
    
    private enum CodingKeys: String, CodingKey {
        case time = "time"
        case title = "title"
        case woeid = "woeid"
        case consolidatedWeather = "consolidated_weather"
    }
    
    struct ConsolidatedWeather: Codable {
        let id: Int
        let weather_state_name: String
        let weather_state_abbr: String
        let wind_direction_compass: String
        let created: String
        let applicable_date: String
        let min_temp: Double
        let max_temp: Double
        let the_temp: Double
        let wind_speed: Double
        let wind_direction: Double
        let air_pressure: Double
        let humidity: Int
        let visibility: Double
        let predictability: Int
    }
}
