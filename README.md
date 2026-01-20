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
- I approached this attempt at the assessment with AI code-gen at the forefront. Again, starting with a starter SwiftUI project in XCode over UIKit in order to utilize the latest framework from Apple, which helps to reduce boiler plate code, and increase speed of development of the UI.
- **Best Practices / SOLID App Arch:** I started a chat with Claude Opus 4.5 using the Conductor app. My plan was to get the agent to think in terms of best practices before writing any code. I first asked Claude to walk me through SOLID design principles, and MVVM architecture in iOS apps, as well as any "gotcha's" when following either of these in iOS applications. With these principles and architecture in mind, I asked it to generate the initial app architecture for the application. (See Prompt 1)
- **Keychain Management:** Claude had created a Keychain management class which directly interacts with the Security framework from Apple. Being the sole developer on this, it would take a decent amount of time to understand the correct way to implement this, and review Claude's code to ensure it was correct. Thus, I replaced Claude's implementation with an open-source library for interacting with the keychain. This gives us many built in features for working with the keychain in the future (i.e. FaceID/Fingerprint, iCloud syncing, and more). There is also much less developer overhead in terms of maintaining this code and adding new features as the Security framework may change in the future, as this work is outsourced to the open-source community.
- **User Interface:** I directed Claude in doing the first pass at the SwiftUI using the following prompt (See Prompt 2). This gave me a good starting point where after I could refine the designs by hand until they matched the Figma designs. I added Fonts and Colors manually and corrected some outdated code that Claude had added (foregroundColor -> foregroundStyle). From here, I kept iterating until the app matched the figma designs. I quickly added a nice-to-have redacted placeholder for the loading state of the Flights view.
- **Unit Tests:** I had Claude add unit tests for the service and state handling classes, as well as the view models, and models. Some of Claudes initial UI code needed refactoring to make it more testable. This mostly consisted of moving logic out of the view and into either a dedicated viewmodel, or finding a more appropriate location for it. A few corrections needed to be made to Claude's unit tests as well. Some tests weren't testing anything useful, such as a loading state test, and some tests were failing due to a race condition related to ObservableObjects.
- **AI Management - Context Window:** I used a single thread in the Conductor app for managing the context window of the AI. I ensured branches and pr's we're created with a single task in mind. I would use the built-in `\compact` command to summarize the AI conversation. This reduces the load on the AI's context window, while still retaining important history from the existing chat. This approach isn't perfect, but it worked well for the scope of this project.
- **AI Management - AI Errors:** AI is still at the point where it needs to be carefully checked and reviewed. AI is progressively getting more advanced, but at this time it still needs careful checking. I would review the AI's code in the tool, where I could make updates immediately as needed. I also created pull requests on github, and thoroughly reviewed the code for mistakes, leaving comments where necessary. This made it easier to track changes I wanted to make, and I could go in and update the code myself, responding to and resolving my own comments as I made fixes.

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