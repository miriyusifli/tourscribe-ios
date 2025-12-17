
📝 Tourscribe - Product Requirements 

ℹ️ Document Status 

Role	Name	Status
Designer		DRAFT
Backend Developers	
@Miri Yusifli 

Frontend Developers		
QA		
Project Manager	
@ramiz omarov 

🗺️ Product Scope 

This product integrates a variety of valuable functionalities to facilitate trip planning and enhance the travel experience by providing comprehensive assistance throughout the journey. Further details regarding the product's features are outlined below.

In the initial phase, the goal is to launch the product as a web application with a highly responsive design, ensuring a smooth interaction for all users, especially those accessing the application through mobile devices. The next steps might consider introducing native mobile apps to enhance user experience for mobile users.

🚀 Requirements 

Importance Definitions 


MUST HAVE: These features must be part of the MVP.


NICE TO HAVE: It would be good to see these features as a part of the initial version of the product.


FURTHER ENHANCEMENTS: These features will be developed later on.

Difficulty Definitions 

EASY 

MODERATE 

HARD 

Feature List
Requirement	Description	Importance	Technical Difficulty
Login/SignUp	
Effortlessly access to the account 

MUST HAVE 

EASY 

Profile	
An account profile to keep personal information, preferences, and other information.

MUST HAVE 

EASY 

Plan	
Effortlessly plan and manage trip itinerary and activities.

MUST HAVE 

EASY 

Expenses	
Effortlessly track and manage expenses throughout your journey, covering dining, transport, activities and etc.

MUST HAVE 

EASY 

Ranking	
This feature introduces a ranking system based on users' yearly travel distances and countries visited. It motivates travelers to explore more, compete for higher ranks, and share achievements with friends.

MUST HAVE 

EASY 

AskMe	
A chatbot to answer questions regarding travel and historical places 

MUST HAVE 

MODERATE 

Visa Advisor	
By entering passport details, users receive a personalized info about visa-free, visa-on-arrival, visa-required countries.

NICE TO HAVE 

HARD 

SpotInfo	
A feature similar to Google Lens, to recognize and assist users in identifying various locations, landmarks, and attractions they wish to get fundamental details such as name, construction date and etc.

FURTHER ENHANCEMENTS 

HARD 

Cost Estimator	
Cost estimator based on provided flight prices and the number of days in each city.

FURTHER ENHANCEMENTS 

HARD 

🔑 Login/Signup 

User Story 

As a user, I anticipate using the signup/login feature. With this functionality, I look forward to effortlessly creating an account or logging in to access my account. The email verification should be used as an additional layer to enhance the security of my account. The email field should be unique per account. For account recovery, email should serve as the method for resetting the password in case it is forgotten.

Design 

email (unique) 

given name 

family name 

gender 

birthdate 

locale (preferred_language) 

created_at (only backend, read-only field) 

updated_at (only backend, read-only field) 

email_verified (only backend, read-only field) 

Dev Notes 

The Cognito pool from AWS should be used for this feature.

👤 Profile 

User Story 

As a user, I look forward to having an account profile within the app. This feature will enable me to store and manage my personal details, and preferences. I anticipate being able to change my name, password, preferred language, etc.

Design 

give name 

family name 

gender 

birthdate 

password 

locale (preferred language) 

created_at (read_only) 

Question: Do we need to make email field updatable? Since it is unique per account and username in Cognito pool.

🗓️ Plan 

User Story 

As a traveler, I anticipate utilizing the app's itinerary planning feature to have a clear, easy-to-use travel plan. This feature will grant me the flexibility to add, modify, and delete different activities based on my preferences and availability.

Once my itinerary is created, I look forward to effortlessly accessing weather details, allowing me to stay informed and adapt my plans. Meanwhile, I would like to be able to share the trip with my friends via a PDF or link as a read-only page. Moreover, as a user, I look forward to a visually pleasing trip overview that aids in tracking the next steps and provides detailed info regarding itineraries at first glance.

As an enthusiastic traveler, I need a convenient way to discover popular attractions in a city I'm about to visit. After inputting my chosen destination, I'd like to receive recommendations for well-known places along with Google reviews and related details. Once I've decided on the places to explore during the day, I'm looking for a solution that can provide me with an efficient route to seamlessly navigate through all the selected locations.

Design 

Name of the trip 

Start and end date time of the trip 

Show recommendations option 

After creating a plan, each item contains the following:

Start/end date time 

Place detailed info about each place.

Transportation type 

QR code for the ticket (optional) 

Notes 

Reminder 

Recommended route / Optimize order of items based on route per day 

Add cost to the item easily 

Travel time between items on the day overview 

Show places on the map 

Show places on the map per day 

Show places on the map based on category (restaurant, etc.) 

☐ Mobile design draft 

☑ 

It would be good to show weather based on start/end date of the trip on view page.

It would be good to have a feature to parse PDF and create trip or an activity of the trip automatically.

Dev Notes 

The plan can be shared as a PDF or read-only page on our website. Needs to be decided on implementation. Consume Places API from Google to implement this page.

💰 Expenses 

User Story 

As a passionate explorer aiming for financial management and collaborative insights, I desire the app to effortlessly assist me in tracking and arranging my expenses during my trips. The feature to categorize costs for accommodations, dining, transport, and diverse activities is essential, as it will provide me with a comprehensive view of my spending behaviors.

Furthermore, I expect this feature to seamlessly integrate visualization of expenses as charts, tables, or graphs to give a better real overview of expenses. Meanwhile, the visualization should contain currency conversion tools under the hood, enabling me to view the visual representation in a preferred currency. Considering the expense date for conversion would be beneficial. This approach ensures that each conversion accurately corresponds to the rate applicable on the expense date, enhancing precision in currency calculations.

In addition to that, I wish to share my expense reports seamlessly with my friends and family. This collaborative feature promises valuable feedback on my spending patterns, allowing me to learn from their experiences and refine my own financial strategies. It would be beneficial if the app prompts for the report's currency and accurately converts expenses accordingly, generating the report in the selected currency.

Design 

Add new expense form 

Name 

Category 

Date 

Currency 

Add new category 

Visualization of expenses 

Share button 

Action points 

☐ Decide predefined categories 

☐ Decide predefined currencies 

Dev Notes 

Displaying the default currency in accordance with the trip's country/city when a user adds a new expense would be highly advantageous. The report can be PDF or read-only page on our website. Needs to be decided on implementation.

🏆 Ranking 

User Story 

As an enthusiastic traveler driven by friendly competition, I am expecting to have a ranking system based on traveled distance and the number of traveled countries. As a user, I look forward to the ability to easily share my achieved ranking with my friends via a link. This feature promises to add an extra layer of excitement to my journeys and a spirit of healthy competition among fellow travelers.

Design 

View based on time range (monthly/yearly) 

Share button 

Dev Notes 

The ranking can be shared as PDF or read-only page on our website. Needs to be decided on implementation.

💬 AskMe 

User Story 

As a curious traveler seeking comprehensive insights, I am excited about the chatbot integration. I expect to effortlessly seek answers to my travel questions regarding history, food, cities and etc.

Design 

Input element for inquires 

Send button 

Output element 

A new chat button 

It may be helpful to have predefined modes such as:

Ask about history.

Ask about food.

and etc.

So, user chooses one of the modes, we create a ChatGPT chat by sending predefined prompt based on selected mode. So, ChatGPT expects questions about the selected topic and provide much more accurate, specific answers.

Dev Notes 

Evaluate the functionality of the ChatGPT API and adapt requirements according to its capabilities. Develop a mechanism to ensure that users utilize ChatGPT for only travel-related tasks, preventing any misuse for other purposes.

🛂 Visa Advisor 

User Story 

As a curious traveler, I'm excited about this feature. With this tool, I anticipate entering my passport details, and the country I want to travel to receive a get detailed info about visa requirements. This personalized insight will enable me to plan my journeys more effectively, uncover fresh travel opportunities, and make informed decisions that align with my passport's capabilities.

Find an API which provides similar features to Passport Index 2023 | World's passports in your pocket.

Design 

The country that issued the user's passport 

A country user wants to travel 

Dev Notes 


How to fetch info about visa requirements? 

Investigate Timatic Solutions 

Check this website Passport Index If it has enough data, deep dive into https://github.com/alsonpr/Henley-Passport-Index-Datase t/blob/main/henley_passport_power.ipynb Connect your Github account to understand how to fetch data from its API. It seems that it is free.

Check this website. Use Case: Get Visa Requirements for a Specific Country (example 2) It requires API access.

In the worst case, we can use a CSV file from this repo : GitHub-ilyankou/passport-index-dataset: Passport Index 2023: visa require ments for 199 countries, in .csv 

Ref: Enriching destination data by using henleyglobal.com Issue #20 ilyankou/passport-index-dataset 

📸 SpotInfo 

User Story 

As a user seeking to explore and identify unfamiliar places and landmarks, I want a convenient way to leverage my phone's camera for assistance. This feature will enable me to effortlessly discover the names of places, landmarks, and objects that I encounter. By capturing a photo and uploading it, I expect to obtain the main details about the image's contents within a brief span of 5-10 seconds. This functionality will greatly enhance my ability to learn about new places and objects through visual recognition.

Design 

Photo upload button 

Progress bar for uploading 

Visual of taken photo 

Loading animation on the processing of images 

Area for output text 

Dev Notes 

I couldn't find a proper API for this feature. I have tested Amazon Rekognition and Google Vision, and both just identify objects such as buildings, grass, and trees in the image. However, our requirement extends beyond identifying individual objects. We need an API that is capable of identifying places, not only individual objects.

It seems that Google Vision API can be utilized to implement this feature. Detect landmarks | Cloud Vision API | Google Cloud 

💸 Cost Estimator 

User Story 

With this tool, I expect to input flight prices and the duration of my stay in each city. This estimator will provide me with an insightful projection of costs for stays, food, and activities, enabling me to plan my expenses effectively and make informed decisions that align with my financial goals.

Google Bard provides better results than ChatGPT for cost estimation.

A request has been sent to SkyScanner to get API access. It seems that they don't provide access to apps which are in the development stage.

We may postpone estimation of flight cost can be developed later, not now.

User interaction and design 

(No further details provided in the source)

🏷️ Pricing 

Feature	Standard	Premium
Travel plan	
1 travel plan per month 

Unlimited travel plan 

Real time currency conversion in expenses	
(Implicitly available in standard, based on blank cell) 

(Implicitly available in premium, based on blank cell) 

AskMe	
5 inquiries per day 

Unlimited number of inquiries 

