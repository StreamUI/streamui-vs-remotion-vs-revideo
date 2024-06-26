import Combine
import Foundation
import NIOSSL
// import NIO
import PostgresNIO

// load in environment variables

public class PeopleFetcher {
    private let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private let client: PostgresClient

    public init() {
        let tlsConfiguration = TLSConfiguration.makeClientConfiguration()

        let config = PostgresClient.Configuration(
            host: ENV.host,
            port: 5432,
            username: ENV.username,
            password: ENV.password,
            database: ENV.database,
            tls: .require(tlsConfiguration)
        )

        self.client = PostgresClient(configuration: config)
    }

    public func fetchPeople() async -> [Person] {
        print("fetching people")
        var fetchedPeople: [Person] = []

        await withThrowingTaskGroup(of: Void.self) { taskGroup in
            taskGroup.addTask {
                await self.client.run()
            }

            print("here")

            let query: PostgresQuery = """
            SELECT name, image_url, ethnicity, openskill_mu, openskill_sigma
            FROM people
            WHERE gender = 'Female'
            ORDER BY RANDOM()
            LIMIT 100
            """

            do {
                print("WUT")
                let rows = try await client.query(query)
                print("Rows", rows)
                for try await (name, imageUrl, ethnicity, openskillMu, openskillSigma) in rows.decode((String, String, String, Double, Double).self) {
                    let person = Person(
                        name: name,
                        image: imageUrl + "?class=mobile",
                        flag: self.getFlagForEthnicity(ethnicity),
                        ethnicity: ethnicity,
                        openskillMu: openskillMu,
                        openskillSigma: openskillSigma
                    )
                    fetchedPeople.append(person)
                }
                print("People", fetchedPeople)
            } catch {
                print("Error fetching people: \(error)")
            }

            taskGroup.cancelAll()
        }

        return fetchedPeople
    }

    private func getFlagForEthnicity(_ ethnicity: String) -> String {
        return ethnicityToFlag[ethnicity] ?? "🌍"
    }
}

let ethnicityToFlag: [String: String] = [
    "Afghan": "🇦🇫",
    "African": "🌍",
    "African American": "🇺🇸",
    "Albanian": "🇦🇱",
    "Algerian": "🇩🇿",
    "American": "🇺🇸",
    "Andorran": "🇦🇩",
    "Angolan": "🇦🇴",
    "Antiguan and Barbudan": "🇦🇬",
    "Argentine": "🇦🇷",
    "Armenian": "🇦🇲",
    "Australian": "🇦🇺",
    "Austrian": "🇦🇹",
    "Azerbaijani": "🇦🇿",
    "Bahamian": "🇧🇸",
    "Bahraini": "🇧🇭",
    "Bangladeshi": "🇧🇩",
    "Barbadian": "🇧🇧",
    "Belarusian": "🇧🇾",
    "Belgian": "🇧🇪",
    "Belizean": "🇧🇿",
    "Beninese": "🇧🇯",
    "Bhutanese": "🇧🇹",
    "Bolivian": "🇧🇴",
    "Bosnian": "🇧🇦",
    "Botswanan": "🇧🇼",
    "Brazilian": "🇧🇷",
    "British": "🇬🇧",
    "Bruneian": "🇧🇳",
    "Bulgarian": "🇧🇬",
    "Burkinabe": "🇧🇫",
    "Burundian": "🇧🇮",
    "Caucasian": "🏳️",
    "Cambodian": "🇰🇭",
    "Cameroonian": "🇨🇲",
    "Canadian": "🇨🇦",
    "Cape Verdean": "🇨🇻",
    "Central African": "🇨🇫",
    "Chadian": "🇹🇩",
    "Chilean": "🇨🇱",
    "Chinese": "🇨🇳",
    "Colombian": "🇨🇴",
    "Comorian": "🇰🇲",
    "Congolese": "🇨🇬",
    "Costa Rican": "🇨🇷",
    "Croatian": "🇭🇷",
    "Cuban": "🇨🇺",
    "Cypriot": "🇨🇾",
    "Czech": "🇨🇿",
    "Danish": "🇩🇰",
    "Djiboutian": "🇩🇯",
    "Dominican": "🇩🇴",
    "Dutch": "🇳🇱",
    "East Timorese": "🇹🇱",
    "Ecuadorian": "🇪🇨",
    "Egyptian": "🇪🇬",
    "Emirati": "🇦🇪",
    "Equatorial Guinean": "🇬🇶",
    "Eritrean": "🇪🇷",
    "Estonian": "🇪🇪",
    "Ethiopian": "🇪🇹",
    "Fijian": "🇫🇯",
    "Finnish": "🇫🇮",
    "French": "🇫🇷",
    "Gabonese": "🇬🇦",
    "Gambian": "🇬🇲",
    "Georgian": "🇬🇪",
    "German": "🇩🇪",
    "Ghanaian": "🇬🇭",
    "Greek": "🇬🇷",
    "Grenadian": "🇬🇩",
    "Guatemalan": "🇬🇹",
    "Guinean": "🇬🇳",
    "Guinea-Bissauan": "🇬🇼",
    "Guyanese": "🇬🇾",
    "Haitian": "🇭🇹",
    "Honduran": "🇭🇳",
    "Hungarian": "🇭🇺",
    "Icelandic": "🇮🇸",
    "Indian": "🇮🇳",
    "Indonesian": "🇮🇩",
    "Iranian": "🇮🇷",
    "Iraqi": "🇮🇶",
    "Irish": "🇮🇪",
    "Israeli": "🇮🇱",
    "Italian": "🇮🇹",
    "Ivorian": "🇨🇮",
    "Jamaican": "🇯🇲",
    "Japanese": "🇯🇵",
    "Jordanian": "🇯🇴",
    "Kazakhstani": "🇰🇿",
    "Kenyan": "🇰🇪",
    "Kiribati": "🇰🇮",
    "Kuwaiti": "🇰🇼",
    "Kyrgyz": "🇰🇬",
    "Laotian": "🇱🇦",
    "Latvian": "🇱🇻",
    "Lebanese": "🇱🇧",
    "Lesotho": "🇱🇸",
    "Liberian": "🇱🇷",
    "Libyan": "🇱🇾",
    "Liechtenstein": "🇱🇮",
    "Lithuanian": "🇱🇹",
    "Luxembourger": "🇱🇺",
    "Macedonian": "🇲🇰",
    "Malagasy": "🇲🇬",
    "Malawian": "🇲🇼",
    "Malaysian": "🇲🇾",
    "Maldivian": "🇲🇻",
    "Malian": "🇲🇱",
    "Maltese": "🇲🇹",
    "Marshallese": "🇲🇭",
    "Mauritanian": "🇲🇷",
    "Mauritian": "🇲🇺",
    "Mexican": "🇲🇽",
    "Micronesian": "🇫🇲",
    "Moldovan": "🇲🇩",
    "Monegasque": "🇲🇨",
    "Mongolian": "🇲🇳",
    "Montenegrin": "🇲🇪",
    "Moroccan": "🇲🇦",
    "Mozambican": "🇲🇿",
    "Namibian": "🇳🇦",
    "Nauruan": "🇳🇷",
    "Nepalese": "🇳🇵",
    "New Zealander": "🇳🇿",
    "Nicaraguan": "🇳🇮",
    "Nigerian": "🇳🇬",
    "Nigerien": "🇳🇪",
    "North Korean": "🇰🇵",
    "Norwegian": "🇳🇴",
    "Omani": "🇴🇲",
    "Pakistani": "🇵🇰",
    "Palauan": "🇵🇼",
    "Palestinian": "🇵🇸",
    "Panamanian": "🇵🇦",
    "Papua New Guinean": "🇵🇬",
    "Paraguayan": "🇵🇾",
    "Peruvian": "🇵🇪",
    "Polish": "🇵🇱",
    "Portuguese": "🇵🇹",
    "Qatari": "🇶🇦",
    "Romanian": "🇷🇴",
    "Russian": "🇷🇺",
    "Rwandan": "🇷🇼",
    "Saint Kitts and Nevis": "🇰🇳",
    "Saint Lucian": "🇱🇨",
    "Saint Vincentian": "🇻🇨",
    "Samoan": "🇼🇸",
    "San Marinese": "🇸🇲",
    "Sao Tomean": "🇸🇹",
    "Saudi Arabian": "🇸🇦",
    "Senegalese": "🇸🇳",
    "Serbian": "🇷🇸",
    "Seychellois": "🇸🇨",
    "Sierra Leonean": "🇸🇱",
    "Singaporean": "🇸🇬",
    "Slovak": "🇸🇰",
    "Slovenian": "🇸🇮",
    "Solomon Islander": "🇸🇧",
    "Somali": "🇸🇴",
    "South African": "🇿🇦",
    "South Korean": "🇰🇷",
    "South Sudanese": "🇸🇸",
    "Spanish": "🇪🇸",
    "Sri Lankan": "🇱🇰",
    "Sudanese": "🇸🇩",
    "Surinamese": "🇸🇷",
    "Swazi": "🇸🇿",
    "Swedish": "🇸🇪",
    "Swiss": "🇨🇭",
    "Syrian": "🇸🇾",
    "Taiwanese": "🇹🇼",
    "Tajik": "🇹🇯",
    "Tanzanian": "🇹🇿",
    "Thai": "🇹🇭",
    "Togolese": "🇹🇬",
    "Tongan": "🇹🇴",
    "Trinidadian and Tobagonian": "🇹🇹",
    "Tunisian": "🇹🇳",
    "Turkish": "🇹🇷",
    "Turkmen": "🇹🇲",
    "Tuvaluan": "🇹🇻",
    "Ugandan": "🇺🇬",
    "Ukrainian": "🇺🇦",
    "Uruguayan": "🇺🇾",
    "Uzbek": "🇺🇿",
    "Vanuatuan": "🇻🇺",
    "Venezuelan": "🇻🇪",
    "Vietnamese": "🇻🇳",
    "Yemeni": "🇾🇪",
    "Zambian": "🇿🇲",
    "Zimbabwean": "🇿🇼"
]
