#  FlexJet Interview (AI Forward)

## Jonathan Kovach

Original Implementation (no AI code-gen): https://github.com/flying-turtle-tech/FlexJet-Interview

### Time Breakdown

- Login screen: 0.5 hours
- Flights screen: 2 hours
- Redacted Loading State with shimmer effect: 0.25 hours
- Unit Tests: 2 hours
- Service Classes: 2 hours

### Approach
- I approached this attempt at the assessment with AI code-gen at the forefront. Similar to my first version, I started with an empty Xcode project with the SwiftUI Template. SwiftUI is the latest UI Framework from Apple. I chose to use SwiftUI over UIKit because SwiftUI makes quickly building and refining views much faster, and simpler, with less boiler plate code.
#### Architecture
- **Service Classes:** In the app you'll find service classes as well as a Service Container. There is a one service class for handling the API requests, one for handling authentication, and another for fetching flights. These classes all conform to their own protocol as well. These separate classes help to separate concerns within the app, and the protocols helps keep the app flexible to future changes. Protocols also help us when it comes to testing. We can Mock our services as needed to avoid expensive calls in our tests (like backend requests). The Service Container is useful for injecting these service into the View classes. We only need a singleton instance of these classes, so the Service Container helps us manage these instances in one location.
- **State Management Classes:** We also have a couple of state management classes. One for Auth, and one for the Flight Completion. The AuthState class directly interacts with the AuthenticationService, and the View classs directly read from the AuthState, so the AuthenticationService remains an internal implementation that is not exposed to any views. This is great for separation of concerns, and the AuthenicationService could easily be replaced in the future if needed. We have a Flight Completion state management class as well that handles saving the flights that are marked as completed to persistent storage. Because we cannot update the backend in this case, saving to persistent storage is our next best solution.
- **View Models:** There are a few ViewModel classes in the application. These ViewModels help to take complex business logic out of the app Views, leading to a cleaner, more readable codebase. The FlightViewModel relies on an instance of the FlightService protocol. This allows for easy replacement of the class that fetches the flight data if ever needed. The LoginViewModel relies on the AuthState ObservableObject class. This allows the app to stay reactive, since the AuthState.isAuthenticated @Published variable is used to show the LoginView v.s. the MainTabView. There are other smaller ViewModels in the app as well that remove some logic from the View to assist with testing. All of these view models help to separate concerns within the app, and make the code more testable. This leading to a more readable and robust codebase.
#### AI Approach
- **AI Management - Context Window:** I used a single thread in the Conductor app for managing the context window of the AI. I ensured branches and pr's we're created with a single task in mind. I would use the built-in `\compact` command to summarize the AI conversation. This reduces the load on the AI's context window, while still retaining important history from the existing chat. This approach isn't perfect, but it worked well for the scope of this project.
- **AI Management - AI Errors:** AI is still at the point where it needs to be carefully checked and reviewed. AI is progressively getting more advanced, but at this time it still needs careful checking. I would review the AI's code in the tool, where I could make updates immediately as needed. I also created pull requests on github, and thoroughly reviewed the code for mistakes, leaving comments where necessary. This made it easier to track changes I wanted to make, and I could go in and update the code myself, responding to and resolving my own comments as I made fixes.
- **Best Practices / SOLID App Arch:** I started a chat with Claude Opus 4.5 using the Conductor app. My plan was to get the agent to think in terms of best practices before writing any code. I first asked Claude to walk me through SOLID design principles, and MVVM architecture in iOS apps, as well as any "gotcha's" when following either of these in iOS applications. With these principles and architecture in mind, I asked it to generate the initial app architecture for the application. (See Prompt 1)
- **Keychain Management:** Claude had created a Keychain management class which directly interacts with the Security framework from Apple. Due to the fact that AI Code still needs to be thoroughly reviewed before submitting to production, I thought it best to replaced Claude's implementation with an open-source library for interacting with the keychain. Not only does this give us many built in features for working with the keychain (i.e. FaceID/Fingerprint, iCloud syncing, and more), but this library is already tried and tested by the community. Using this library also provides us with less developer maintenance of this code. If the Security framework were to change in the future this library presumably may update with it, and updating would be as simple as updating a version number in the Package.swift.
- **User Interface:** I directed Claude to do the first pass at the SwiftUI using the following prompt (See Prompt 2). This gave me a good starting point where after I could refine the app views by hand until they matched the Figma designs. I added Fonts and Colors manually and corrected some outdated code that Claude had added (foregroundColor -> foregroundStyle). From here, I kept iterating until the app matched the figma designs. I quickly added a nice-to-have redacted placeholder for the loading state of the Flights view. This loading state also shimmers to show a loading state. This was quickly achieved with the use of Claude.
- **Unit Tests:** I had Claude add unit tests for the service and state handling classes, as well as the view models, and models. Some of Claudes initial UI code needed refactoring to make it more testable. This mostly consisted of moving logic out of the view and into either a dedicated viewmodel, or finding a more appropriate location for it. A few corrections needed to be made to Claude's unit tests as well. Some tests weren't testing anything useful, such as a loading state test, and some tests were failing due to a race condition related to ObservableObjects.

### Prompts:

#### Prompt 1 - Service classes:
> Keeping that SOLID design principles, MVVM, and the gotchyas in mind, lets setup the basic architecture for my application. I will detail what's needed. \
API Requests: We need to be able to make two API requests. One for logging in. The other for fetching flights. Root URL: `https://v0-simple-authentication-api.vercel.app/` \
Login via POST /api/signIn - Request body:
```
{  
  "username": "john",
  "password": "12345"
}
```
> Fetch Flights via GET /api/flights \
Authorization: Bearer <token-from-signin> \
Response body - Success: \
```
[
  {
    "id": "FL006",
    "tripNumber": "1234567",
    "flightNumber": "UA890", // Optional
    "tailNumber": "N987UA",
    "origin": "Las Vegas (LAS)",
    "originIata": "LAS",
    "destination": "New York (JFK)",
    "destinationIata": "JFK",
    "departure": "2026-01-08T09:20:00.000Z",
    "arrival": "2026-01-08T12:20:00.000Z",
    "price": 10800
  }
  // ... more flights
]
```
> Response Body - Error \
{
    "error": "Invalid or expired token"
}\
\
We need to make sure the departure and arrival are converted correctly to the Swift representation of Date. Note that Price is in cents. \
\
Lets add the necessary model and service classes and that a viewmodel could utilize. There should be an authentication class that saves the token to the keychain. Keep in mind handling errors gracefully. For instance we should be able to detect if the users token expired.

#### Prompt 2 - UI First Pass:
> Create a new branch off of main, we will start adding the SwiftUI views:
Login Page: A simple login page that takes a username, and password with a submit button. Handles errors gracefully by showing any user facing error to the user. Makes the signin request \
\
Main Page: A tab bar with the following tabs - Flights (airplane), Favorites (heart), Contracts (signature) and Profile (person). We will only focus on the Flights tab for now. \
\
Flights Page: Shows a card preview for each flight. (Must make the flight request) The view is described from top down: \
-Title (Flights) Right of title (plus.square.fill) button \
-Segmented Control (Upcoming - Past) -- Flight is upcoming if the Flight is today and earlier and has not departed. If the flight is today and has not departed it will have a flight today badge \
-List of Flight Cards \
\
Flight Card: Shows a preview of the flight. From left to right: \
-Custom Calendar view (3 letter month abbreviation above the day of the month) \
-<departure> to <arrival> i.e. New York to London, above the departure time and arrival time. Ensure the timezone adapts to the current users timezone. Display flight times in the current user timezone. \
-Checkmark (checkmark.seal) \
\
Clicking in to one of the cards takes the user to a Flight Detail Page that displays all the day we have for the flight in a nice orderly way. \
Flight Details page: From top to Bottom \
-Back button \
-LAS to JFK (dynamic based on data) \
-Two horizontal cards with Departure airport above "Origin", and Arrival aiport above "Destination". i.e. Las Vegas (LAS) \n Origin \
-Departure date <departure data (#w ago)> \
-Trip Number <Trip Number> \
-Flight Number <Flight Number> \
-Tail Number <Tail Number> \
-Price <Formatted Price> \
-Completed button \
  -Uncompleted state: Checkmark.seal "Complete". White with grey 1pt border \
  -Completed state: Checkmark.seal.fill (white) "Completed". #92262c. \
  -WARNING - GOTCHYA ALERT - When setting the completed state, the Checkmark on the Flight Card should update. In the completed state it should be filled in the #92262c color. When not completed it should be the non filled checkmark.seal with a black border.


### Future Enhancements
- [ ] Implement caching properly for requests. Possibly add a networking library that automatically handles caching.
- [ ] Perfecting token expiration on flights page. Point user to login again.
- [ ] Use static String variables for any strings that are displayed in the app
- [ ] Replace magic numbers with descriptive variables.
- [ ] Fix any broken Preview Views.
- [ ] Add an app icon
- [ ] Add Swift Linter/Formatter so that code is all formatted the same throughout
- [ ] Add a pipeline to automatically test code on PR's

### Future updates that require backend updates
- [ ] Automatic background token refresh.
- [ ] Make the Plus button on flights page add a flight.
- [ ] Create pages for other tabs. (Favorites, Contracts, Profile)
