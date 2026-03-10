# frozen_string_literal: true

# Idempotent seed file for visual/manual testing.
# Safe to run multiple times — uses find_or_create_by! on unique fields.
#
# Usage:
#   rails db:seed                  # Add seed data (safe to re-run)
#   SEED_RESET=1 rails db:seed    # Clear all data first, then re-seed

if ENV["SEED_RESET"]
  puts "Clearing existing data..."
  [Attendance, Follow, Event, User, Organization].each(&:delete_all)
end

# ---------------------------------------------------------------------------
# Organizations (15)
# ---------------------------------------------------------------------------
puts "Seeding organizations..."

org_data = [
  {
    name: "Nashville Hope Foundation",
    email: "info@nashvillehope.org",
    description: "Empowering Nashville communities through education scholarships, after-school programs, and mentorship initiatives for underserved youth.",
    primary_cause: "Education",
    causes: ["Education", "Youth Development"],
    industries: ["Nonprofit", "Education"],
    website: "https://nashvillehope.org",
    phone: "(615) 555-0101"
  },
  {
    name: "Austin Health Alliance",
    email: "contact@austinhealthalliance.org",
    description: "Providing free healthcare clinics and wellness programs to uninsured families across Central Texas.",
    primary_cause: "Health",
    causes: ["Health", "Mental Health"],
    industries: ["Healthcare", "Nonprofit"],
    website: "https://austinhealthalliance.org",
    phone: "(512) 555-0202"
  },
  {
    name: "New York Arts Collective",
    email: "hello@nyartscollective.org",
    description: "Bringing world-class arts programming to underserved neighborhoods throughout the five boroughs.",
    primary_cause: "Arts & Culture",
    causes: ["Arts & Culture", "Education"],
    industries: ["Entertainment", "Nonprofit"],
    website: "https://nyartscollective.org",
    phone: "(212) 555-0303"
  },
  {
    name: "Chicago Green Initiative",
    email: "info@chicagogreen.org",
    description: "Urban reforestation, community gardens, and clean energy advocacy for a greener Chicago.",
    primary_cause: "Environment",
    causes: ["Environment", "Community Development"],
    industries: ["Energy", "Nonprofit"],
    website: "https://chicagogreen.org",
    phone: "(312) 555-0404"
  },
  {
    name: "LA Animal Rescue Network",
    email: "adopt@laanimalrescue.org",
    description: "Rescuing, rehabilitating, and rehoming animals across Los Angeles County since 2008.",
    primary_cause: "Animal Welfare",
    causes: ["Animal Welfare"],
    industries: ["Nonprofit"],
    website: "https://laanimalrescue.org",
    phone: "(323) 555-0505"
  },
  {
    name: "Miami Justice Project",
    email: "info@miamijustice.org",
    description: "Legal aid and advocacy for marginalized communities in South Florida.",
    primary_cause: "Social Justice",
    causes: ["Social Justice", "Housing"],
    industries: ["Legal", "Nonprofit"],
    website: "https://miamijustice.org",
    phone: "(305) 555-0606"
  },
  {
    name: "Denver Food Bank Coalition",
    email: "help@denverfoodbank.org",
    description: "Fighting hunger across the Front Range through food distribution, community kitchens, and nutrition education.",
    primary_cause: "Hunger & Poverty",
    causes: ["Hunger & Poverty", "Community Development"],
    industries: ["Nonprofit"],
    website: "https://denverfoodbank.org",
    phone: "(720) 555-0707"
  },
  {
    name: "Seattle Veterans Alliance",
    email: "support@seavets.org",
    description: "Housing, employment, and mental health support for veterans and military families in the Pacific Northwest.",
    primary_cause: "Veterans",
    causes: ["Veterans", "Mental Health", "Housing"],
    industries: ["Nonprofit", "Healthcare"],
    website: "https://seavets.org",
    phone: "(206) 555-0808"
  },
  {
    name: "Atlanta Youth Futures",
    email: "info@atlantayouthfutures.org",
    description: "STEM education, leadership training, and college prep for Atlanta's next generation.",
    primary_cause: "Youth Development",
    causes: ["Youth Development", "Education"],
    industries: ["Technology", "Nonprofit"],
    website: "https://atlantayouthfutures.org",
    phone: "(404) 555-0909"
  },
  {
    name: "San Francisco Mind & Body",
    email: "hello@sfmindbody.org",
    description: "Accessible therapy, meditation programs, and crisis support for Bay Area residents.",
    primary_cause: "Mental Health",
    causes: ["Mental Health", "Health"],
    industries: ["Healthcare", "Nonprofit"],
    website: "https://sfmindbody.org",
    phone: "(415) 555-1010"
  },
  {
    name: "Portland Housing First",
    email: "info@pdxhousingfirst.org",
    description: "Building affordable housing and providing transitional shelter for Portland's homeless population.",
    primary_cause: "Housing",
    causes: ["Housing", "Community Development"],
    industries: ["Real Estate", "Nonprofit"],
    website: "https://pdxhousingfirst.org",
    phone: "(503) 555-1111"
  },
  {
    name: "Houston Disaster Relief Fund",
    email: "relief@houstonrelief.org",
    description: "Rapid response and long-term recovery support for Gulf Coast communities affected by natural disasters.",
    primary_cause: "Disaster Relief",
    causes: ["Disaster Relief", "Housing"],
    industries: ["Nonprofit", "Finance"],
    website: "https://houstonrelief.org",
    phone: "(713) 555-1212"
  },
  {
    name: "Philadelphia Community Builders",
    email: "build@phillycommunity.org",
    description: "Neighborhood revitalization, small business grants, and community center programming across Philadelphia.",
    primary_cause: "Community Development",
    causes: ["Community Development", "Education"],
    industries: ["Nonprofit", "Real Estate"],
    website: "https://phillycommunity.org",
    phone: "(215) 555-1313"
  },
  {
    name: "Boston Science Research Trust",
    email: "grants@bostonsciencetrust.org",
    description: "Funding breakthrough medical and environmental research at universities across New England.",
    primary_cause: "Science & Research",
    causes: ["Science & Research", "Health"],
    industries: ["Technology", "Healthcare"],
    website: "https://bostonsciencetrust.org",
    phone: "(617) 555-1414"
  },
  {
    name: "Dallas Women's Empowerment League",
    email: "info@dallaswel.org",
    description: "Career development, entrepreneurship training, and leadership programs for women in North Texas.",
    primary_cause: "Women's Empowerment",
    causes: ["Women's Empowerment", "Education"],
    industries: ["Finance", "Nonprofit"],
    website: "https://dallaswel.org",
    phone: "(214) 555-1515"
  }
]

organizations = org_data.map do |attrs|
  Organization.find_or_create_by!(email: attrs[:email]) do |org|
    org.assign_attributes(attrs.except(:email).merge(password: "password"))
  end
end

puts "  #{Organization.count} organizations"

# ---------------------------------------------------------------------------
# Users (50)
# ---------------------------------------------------------------------------
puts "Seeding users..."

user_names = [
  ["Emma", "Thompson"], ["Liam", "Chen"], ["Olivia", "Rodriguez"], ["Noah", "Patel"],
  ["Ava", "Williams"], ["Ethan", "Kim"], ["Sophia", "Davis"], ["Mason", "Garcia"],
  ["Isabella", "Martinez"], ["James", "Anderson"], ["Mia", "Taylor"], ["Benjamin", "Wilson"],
  ["Charlotte", "Moore"], ["Lucas", "Jackson"], ["Amelia", "White"], ["Henry", "Harris"],
  ["Harper", "Clark"], ["Alexander", "Lewis"], ["Evelyn", "Robinson"], ["Sebastian", "Walker"],
  ["Abigail", "Hall"], ["Jack", "Allen"], ["Emily", "Young"], ["Daniel", "King"],
  ["Elizabeth", "Wright"], ["Michael", "Scott"], ["Sofia", "Green"], ["Matthew", "Adams"],
  ["Avery", "Baker"], ["David", "Nelson"], ["Ella", "Hill"], ["Joseph", "Ramirez"],
  ["Scarlett", "Campbell"], ["Samuel", "Mitchell"], ["Grace", "Roberts"], ["Owen", "Carter"],
  ["Chloe", "Phillips"], ["William", "Evans"], ["Lily", "Turner"], ["Jackson", "Torres"],
  ["Penelope", "Parker"], ["Aiden", "Collins"], ["Layla", "Edwards"], ["Luke", "Stewart"],
  ["Riley", "Flores"], ["Gabriel", "Morris"], ["Zoey", "Nguyen"], ["Carter", "Murphy"],
  ["Nora", "Rivera"], ["Jayden", "Cooper"]
]

cities_states = [
  ["Nashville", "TN"], ["Austin", "TX"], ["New York", "NY"], ["Chicago", "IL"],
  ["Los Angeles", "CA"], ["Miami", "FL"], ["Denver", "CO"], ["Seattle", "WA"],
  ["Atlanta", "GA"], ["San Francisco", "CA"], ["Portland", "OR"], ["Houston", "TX"],
  ["Philadelphia", "PA"], ["Boston", "MA"], ["Dallas", "TX"]
]

all_causes = [
  "Education", "Health", "Arts & Culture", "Environment", "Animal Welfare",
  "Social Justice", "Hunger & Poverty", "Veterans", "Youth Development",
  "Mental Health", "Housing", "Disaster Relief", "Community Development",
  "Science & Research", "Women's Empowerment"
]

all_industries = [
  "Nonprofit", "Healthcare", "Technology", "Finance",
  "Real Estate", "Entertainment", "Legal", "Energy"
]

bios = [
  "Passionate about making a difference in my community.",
  "Event enthusiast and philanthropist.",
  "Love attending galas and supporting great causes.",
  "Tech professional who believes in giving back.",
  "Dedicated to supporting arts and education.",
  "Healthcare worker committed to community wellness.",
  "Entrepreneur with a heart for social impact.",
  "Lifelong volunteer and community organizer.",
  nil
]

srand(42) # Deterministic randomness for reproducible seeds

users = user_names.each_with_index.map do |(first, last), i|
  city, state = cities_states[i % cities_states.size]
  email = "#{first.downcase}.#{last.downcase}@example.com"
  username = "#{first.downcase}#{last.downcase}"

  User.find_or_create_by!(email: email) do |u|
    u.first_name = first
    u.last_name = last
    u.username = username
    u.password = "password"
    u.bio = bios.sample
    u.city = city
    u.state = state
    u.sex = ["Male", "Female"].sample
    u.birthdate = Date.new(1970 + rand(35), 1 + rand(12), 1 + rand(28))
    u.visibility = i < 45 # ~10% hidden
    u.visibility_email = [true, false, false, false].sample
    u.visibility_full_name = true
    u.interested_causes = all_causes.sample(2 + rand(3))
    u.interested_industries = all_industries.sample(1 + rand(3))
    u.social_instagram = ["@#{username}", nil].sample
    u.social_x = ["@#{username}", nil].sample
    u.social_linkedin = [username, nil].sample
  end
end

puts "  #{User.count} users"

# ---------------------------------------------------------------------------
# Events (65)
# ---------------------------------------------------------------------------
puts "Seeding events..."

dress_codes = Event.dress_codes.keys
today = Date.current

event_templates = [
  # Nashville events
  { org: 0, title: "Spring Charity Gala", venue: "The Hermitage Hotel", city: "Nashville", state: "TN", street: "231 6th Ave N", zip: "37219", price: 250.00, dress: "black_tie", days: 14, hashtags: ["#NashvilleGala", "#SpringCharity"] },
  { org: 0, title: "Education Excellence Awards Dinner", venue: "Country Music Hall of Fame", city: "Nashville", state: "TN", street: "222 Rep. John Lewis Way S", zip: "37203", price: 175.00, dress: "black_tie_optional", days: 45, hashtags: ["#EducationExcellence"] },
  { org: 0, title: "Back to School Fundraiser Brunch", venue: "The Graduate Nashville", city: "Nashville", state: "TN", street: "101 20th Ave N", zip: "37203", price: 75.00, dress: "business_casual", days: 90, hashtags: ["#BackToSchool", "#NashvilleHope"] },
  { org: 0, title: "Holiday Hope Gala", venue: "Schermerhorn Symphony Center", city: "Nashville", state: "TN", street: "1 Symphony Pl", zip: "37201", price: 300.00, dress: "festive_black_tie", days: 210, hashtags: ["#HolidayHope"] },

  # Austin events
  { org: 1, title: "Heart of Texas Health Benefit", venue: "The Driskill Hotel", city: "Austin", state: "TX", street: "604 Brazos St", zip: "78701", price: 200.00, dress: "cocktail_attire", days: 21, hashtags: ["#HeartOfTexas", "#HealthBenefit"] },
  { org: 1, title: "Wellness Walk & Wine Tasting", venue: "Umlauf Sculpture Garden", city: "Austin", state: "TX", street: "605 Azie Morton Rd", zip: "78704", price: 50.00, dress: "business_casual", days: 60, hashtags: ["#WellnessWalk"] },
  { org: 1, title: "Mental Health Awareness Gala", venue: "Austin Central Library", city: "Austin", state: "TX", street: "710 W Cesar Chavez St", zip: "78701", price: 150.00, dress: "formal", days: 120, hashtags: ["#MentalHealthMatters"] },

  # New York events
  { org: 2, title: "Metropolitan Arts Ball", venue: "The Plaza Hotel", city: "New York", state: "NY", street: "768 5th Ave", zip: "10019", price: 500.00, dress: "black_tie", days: 30, hashtags: ["#MetArtsBall", "#NYCArts"], auction: true },
  { org: 2, title: "Gallery Night Fundraiser", venue: "The Whitney Museum", city: "New York", state: "NY", street: "99 Gansevoort St", zip: "10014", price: 150.00, dress: "cocktail_attire", days: 75, hashtags: ["#GalleryNight"] },
  { org: 2, title: "Broadway Stars Charity Concert", venue: "Carnegie Hall", city: "New York", state: "NY", street: "881 7th Ave", zip: "10019", price: 350.00, dress: "formal", days: 135, hashtags: ["#BroadwayStars", "#CharityConcert"] },
  { org: 2, title: "Public Art Gala", venue: "The Met Breuer", city: "New York", state: "NY", street: "945 Madison Ave", zip: "10021", price: 1000.00, dress: "black_tie", days: 180, hashtags: ["#PublicArtGala"], auction: true, gifts: true },

  # Chicago events
  { org: 3, title: "Green Chicago Dinner", venue: "The Art Institute of Chicago", city: "Chicago", state: "IL", street: "111 S Michigan Ave", zip: "60603", price: 175.00, dress: "formal", days: 18, hashtags: ["#GreenChicago"] },
  { org: 3, title: "Earth Day Celebration Gala", venue: "Shedd Aquarium", city: "Chicago", state: "IL", street: "1200 S DuSable Lk Shr Dr", zip: "60605", price: 125.00, dress: "cocktail_attire", days: 50, hashtags: ["#EarthDay", "#ChicagoGreen"] },
  { org: 3, title: "Lakefront Clean Energy Benefit", venue: "Navy Pier", city: "Chicago", state: "IL", street: "600 E Grand Ave", zip: "60611", price: 200.00, dress: "business_casual", days: 100, hashtags: ["#CleanEnergy"] },
  { org: 3, title: "Winter Solstice Green Gala", venue: "Field Museum", city: "Chicago", state: "IL", street: "1400 S DuSable Lk Shr Dr", zip: "60605", price: 275.00, dress: "festive", days: 225, hashtags: ["#WinterSolstice"] },

  # Los Angeles events
  { org: 4, title: "Paws & Claws Charity Ball", venue: "The Beverly Hilton", city: "Los Angeles", state: "CA", street: "9876 Wilshire Blvd", zip: "90210", price: 400.00, dress: "black_tie_optional", days: 25, hashtags: ["#PawsAndClaws", "#AdoptDontShop"], auction: true },
  { org: 4, title: "Rescue Run 5K & Brunch", venue: "Griffith Park", city: "Los Angeles", state: "CA", street: "4730 Crystal Springs Dr", zip: "90027", price: 0.00, dress: "business_casual", days: 55, hashtags: ["#RescueRun"] },
  { org: 4, title: "Hollywood Tails Fundraiser", venue: "SoFi Stadium", city: "Los Angeles", state: "CA", street: "1001 Stadium Dr", zip: "90301", price: 250.00, dress: "cocktail_attire", days: 150, hashtags: ["#HollywoodTails"] },

  # Miami events
  { org: 5, title: "Justice Under the Stars Gala", venue: "Vizcaya Museum", city: "Miami", state: "FL", street: "3251 S Miami Ave", zip: "33129", price: 350.00, dress: "black_tie", days: 35, hashtags: ["#JusticeGala", "#MiamiJustice"] },
  { org: 5, title: "Community Legal Aid Dinner", venue: "Pérez Art Museum", city: "Miami", state: "FL", street: "1103 Biscayne Blvd", zip: "33132", price: 125.00, dress: "formal", days: 80, hashtags: ["#LegalAid"] },
  { org: 5, title: "Housing Rights Benefit", venue: "Frost Science Museum", city: "Miami", state: "FL", street: "1101 Biscayne Blvd", zip: "33132", price: 100.00, dress: "business_casual", days: 160, hashtags: ["#HousingRights"] },

  # Denver events
  { org: 6, title: "Mile High Harvest Dinner", venue: "Denver Botanic Gardens", city: "Denver", state: "CO", street: "1007 York St", zip: "80206", price: 150.00, dress: "cocktail_attire", days: 22, hashtags: ["#MileHighHarvest"] },
  { org: 6, title: "Feed the Front Range Gala", venue: "Denver Art Museum", city: "Denver", state: "CO", street: "100 W 14th Ave Pkwy", zip: "80204", price: 200.00, dress: "formal", days: 70, hashtags: ["#FeedTheFrontRange"] },
  { org: 6, title: "Thanksgiving Community Feast", venue: "Colorado Convention Center", city: "Denver", state: "CO", street: "700 14th St", zip: "80202", price: 0.00, dress: "business_casual", days: 195, hashtags: ["#CommunityFeast"] },

  # Seattle events
  { org: 7, title: "Veterans Honor Gala", venue: "The Fairmont Olympic", city: "Seattle", state: "WA", street: "411 University St", zip: "98101", price: 300.00, dress: "black_tie", days: 28, hashtags: ["#VeteransHonor", "#SeattleVets"], gifts: true },
  { org: 7, title: "Salute to Service Dinner", venue: "Museum of Flight", city: "Seattle", state: "WA", street: "9404 E Marginal Way S", zip: "98108", price: 175.00, dress: "corporate", days: 85, hashtags: ["#SaluteToService"] },
  { org: 7, title: "Veterans Mental Health Symposium & Gala", venue: "Seattle Convention Center", city: "Seattle", state: "WA", street: "705 Pike St", zip: "98101", price: 100.00, dress: "business_casual", days: 140, hashtags: ["#VetsMentalHealth"] },
  { org: 7, title: "Holiday Heroes Ball", venue: "Chihuly Garden and Glass", city: "Seattle", state: "WA", street: "305 Harrison St", zip: "98109", price: 250.00, dress: "festive_black_tie", days: 230, hashtags: ["#HolidayHeroes"], gifts: true },

  # Atlanta events
  { org: 8, title: "STEM Stars Gala", venue: "Georgia Aquarium", city: "Atlanta", state: "GA", street: "225 Baker St NW", zip: "30313", price: 225.00, dress: "black_tie_optional", days: 32, hashtags: ["#STEMStars", "#AtlantaYouth"], auction: true },
  { org: 8, title: "Future Leaders Scholarship Dinner", venue: "Atlanta History Center", city: "Atlanta", state: "GA", street: "130 W Paces Ferry Rd NW", zip: "30305", price: 150.00, dress: "formal", days: 65, hashtags: ["#FutureLeaders"] },
  { org: 8, title: "Code & Community Hackathon Gala", venue: "Ponce City Market", city: "Atlanta", state: "GA", street: "675 Ponce De Leon Ave NE", zip: "30308", price: 75.00, dress: "business_casual", days: 110, hashtags: ["#CodeAndCommunity"] },
  { org: 8, title: "Youth Innovation Awards", venue: "High Museum of Art", city: "Atlanta", state: "GA", street: "1280 Peachtree St NE", zip: "30309", price: 175.00, dress: "cocktail_attire", days: 175, hashtags: ["#YouthInnovation"] },

  # San Francisco events
  { org: 9, title: "Mindfulness in the City Gala", venue: "Asian Art Museum", city: "San Francisco", state: "CA", street: "200 Larkin St", zip: "94102", price: 200.00, dress: "cocktail_attire", days: 20, hashtags: ["#MindfulnessGala"] },
  { org: 9, title: "Bay Area Wellness Night", venue: "Exploratorium", city: "San Francisco", state: "CA", street: "Pier 15", zip: "94111", price: 125.00, dress: "business_casual", days: 58, hashtags: ["#BayAreaWellness"] },
  { org: 9, title: "Golden Gate Mental Health Benefit", venue: "Palace of Fine Arts", city: "San Francisco", state: "CA", street: "3601 Lyon St", zip: "94123", price: 350.00, dress: "black_tie", days: 130, hashtags: ["#GoldenGateBenefit"], auction: true },

  # Portland events
  { org: 10, title: "Home for All Gala", venue: "Portland Art Museum", city: "Portland", state: "OR", street: "1219 SW Park Ave", zip: "97205", price: 175.00, dress: "formal", days: 38, hashtags: ["#HomeForAll"] },
  { org: 10, title: "Build Together Benefit Dinner", venue: "Oregon Convention Center", city: "Portland", state: "OR", street: "777 NE Martin Luther King Jr Blvd", zip: "97232", price: 100.00, dress: "corporate", days: 95, hashtags: ["#BuildTogether"] },
  { org: 10, title: "Housing Hope Holiday Party", venue: "McMenamins Crystal Ballroom", city: "Portland", state: "OR", street: "1332 W Burnside St", zip: "97209", price: 50.00, dress: "festive", days: 220, hashtags: ["#HousingHope"], gifts: true },

  # Houston events
  { org: 11, title: "Hurricane Relief Gala", venue: "The Post Oak Hotel", city: "Houston", state: "TX", street: "1600 West Loop S", zip: "77027", price: 500.00, dress: "black_tie", days: 40, hashtags: ["#HurricaneRelief", "#HoustonStrong"], auction: true },
  { org: 11, title: "Rebuild Together Dinner", venue: "Space Center Houston", city: "Houston", state: "TX", street: "1601 E NASA Pkwy", zip: "77058", price: 200.00, dress: "cocktail_attire", days: 105, hashtags: ["#RebuildTogether"] },
  { org: 11, title: "Gulf Coast Resilience Ball", venue: "Museum of Fine Arts Houston", city: "Houston", state: "TX", street: "1001 Bissonnet St", zip: "77005", price: 300.00, dress: "black_tie_optional", days: 170, hashtags: ["#GulfCoastResilience"] },

  # Philadelphia events
  { org: 12, title: "Neighborhood Revival Gala", venue: "Philadelphia Museum of Art", city: "Philadelphia", state: "PA", street: "2600 Benjamin Franklin Pkwy", zip: "19130", price: 225.00, dress: "black_tie", days: 42, hashtags: ["#NeighborhoodRevival"] },
  { org: 12, title: "Small Business Saturday Benefit", venue: "Reading Terminal Market", city: "Philadelphia", state: "PA", street: "51 N 12th St", zip: "19107", price: 0.00, dress: "business_casual", days: 115, hashtags: ["#SmallBusinessSaturday"] },
  { org: 12, title: "Philly Builder Awards", venue: "Kimmel Center", city: "Philadelphia", state: "PA", street: "300 S Broad St", zip: "19102", price: 150.00, dress: "formal", days: 185, hashtags: ["#PhillyBuilders"] },

  # Boston events
  { org: 13, title: "Innovation & Discovery Gala", venue: "Boston Museum of Science", city: "Boston", state: "MA", street: "1 Museum of Science Driveway", zip: "02114", price: 400.00, dress: "black_tie", days: 33, hashtags: ["#InnovationGala", "#BostonScience"], auction: true },
  { org: 13, title: "Research Futures Dinner", venue: "Harvard Club of Boston", city: "Boston", state: "MA", street: "374 Commonwealth Ave", zip: "02215", price: 250.00, dress: "formal", days: 78, hashtags: ["#ResearchFutures"] },
  { org: 13, title: "Lab to Life Fundraiser", venue: "New England Aquarium", city: "Boston", state: "MA", street: "1 Central Wharf", zip: "02110", price: 150.00, dress: "cocktail_attire", days: 145, hashtags: ["#LabToLife"] },
  { org: 13, title: "Winter Science Ball", venue: "Isabella Stewart Gardner Museum", city: "Boston", state: "MA", street: "25 Evans Way", zip: "02115", price: 500.00, dress: "festive_black_tie", days: 240, hashtags: ["#WinterScienceBall"], auction: true, gifts: true },

  # Dallas events
  { org: 14, title: "Women Who Lead Gala", venue: "AT&T Performing Arts Center", city: "Dallas", state: "TX", street: "2403 Flora St", zip: "75201", price: 275.00, dress: "black_tie", days: 26, hashtags: ["#WomenWhoLead", "#DallasWEL"] },
  { org: 14, title: "Empower Her Luncheon", venue: "The Adolphus Hotel", city: "Dallas", state: "TX", street: "1321 Commerce St", zip: "75202", price: 100.00, dress: "business_casual", days: 68, hashtags: ["#EmpowerHer"] },
  { org: 14, title: "Entrepreneurship Awards Night", venue: "Perot Museum of Nature and Science", city: "Dallas", state: "TX", street: "2201 N Field St", zip: "75201", price: 200.00, dress: "cocktail_attire", days: 125, hashtags: ["#EntrepreneurshipAwards"] },
  { org: 14, title: "Year-End Empowerment Ball", venue: "Dallas Museum of Art", city: "Dallas", state: "TX", street: "1717 N Harwood St", zip: "75201", price: 350.00, dress: "black_tie_optional", days: 200, hashtags: ["#EmpowermentBall"], gifts: true },

  # Cross-org / premium events
  { org: 2, title: "New Year's Eve Charity Spectacular", venue: "The Rainbow Room", city: "New York", state: "NY", street: "30 Rockefeller Plaza", zip: "10112", price: 2500.00, dress: "black_tie", days: 250, hashtags: ["#NYECharity", "#Spectacular"], auction: true, gifts: true },
  { org: 4, title: "Celebrity Pet Adoption Gala", venue: "Hollywood Roosevelt Hotel", city: "Los Angeles", state: "CA", street: "7000 Hollywood Blvd", zip: "90028", price: 1000.00, dress: "black_tie_optional", days: 190, hashtags: ["#CelebrityPetGala"], auction: true },
  { org: 0, title: "Music City Charity Classic", venue: "Ryman Auditorium", city: "Nashville", state: "TN", street: "116 Rep. John Lewis Way N", zip: "37219", price: 5000.00, dress: "black_tie", days: 155, hashtags: ["#MusicCityClassic", "#Nashville"], auction: true, gifts: true },
  { org: 9, title: "Tech for Good Summit Dinner", venue: "Moscone Center", city: "San Francisco", state: "CA", street: "747 Howard St", zip: "94103", price: nil, dress: "corporate", days: 88, hashtags: ["#TechForGood"] },
  { org: 3, title: "Corporate Sustainability Summit", venue: "The Langham Chicago", city: "Chicago", state: "IL", street: "330 N Wabash Ave", zip: "60611", price: nil, dress: "corporate_festive", days: 98, hashtags: ["#SustainabilitySummit"] },
]

# Add a few draft events
draft_events = [
  { org: 0, title: "Summer Planning Gala (TBD)", venue: nil, city: "Nashville", state: "TN", price: nil, dress: "black_tie", days: 200, status: :draft },
  { org: 5, title: "Miami Beach Justice Evening (TBD)", venue: nil, city: "Miami", state: "FL", price: nil, dress: "cocktail_attire", days: 180, status: :draft },
  { org: 8, title: "Atlanta Tech Youth Summit (TBD)", venue: nil, city: "Atlanta", state: "GA", price: nil, dress: "business_casual", days: 160, status: :draft },
  { org: 13, title: "Boston Biotech Ball (TBD)", venue: nil, city: "Boston", state: "MA", price: nil, dress: "formal", days: 220, status: :draft },
  { org: 14, title: "Dallas Leadership Retreat (TBD)", venue: nil, city: "Dallas", state: "TX", price: nil, dress: "corporate", days: 240, status: :draft },
]

all_event_data = event_templates + draft_events

events = all_event_data.map do |t|
  org = organizations[t[:org]]
  Event.find_or_create_by!(title: t[:title], organization: org) do |e|
    e.date = today + t[:days].days
    e.start_time = Time.zone.parse("18:00") unless t[:status] == :draft
    e.end_time = Time.zone.parse("23:00") unless t[:status] == :draft
    e.venue_name = t[:venue]
    e.city = t[:city]
    e.state = t[:state]
    e.street_address = t[:street]
    e.zip = t[:zip]
    e.starting_ticket_price = t[:price]
    e.dress_code = t[:dress]
    e.status = t[:status] || :published
    e.hashtags = t[:hashtags] || []
    e.auction_items = t[:auction] || false
    e.gift_items = t[:gifts] || false
    e.description = "Join #{org.name} for an unforgettable evening of philanthropy, community, and celebration. Your support directly funds our mission to make a lasting impact."
  end
end

puts "  #{Event.count} events (#{Event.published.count} published, #{Event.where(status: :draft).count} draft)"

# ---------------------------------------------------------------------------
# Attendances (~150) — deterministic assignment based on index
# ---------------------------------------------------------------------------
puts "Seeding attendances..."

published_events = events.select { |e| e.published? }

users.each_with_index do |user, i|
  # Each user attends 2-4 events, determined by their index
  count = 2 + (i % 3)
  count.times do |j|
    event = published_events[(i * 3 + j * 7) % published_events.size]
    Attendance.find_or_create_by!(user: user, event: event)
  end
end

puts "  #{Attendance.count} attendances"

# ---------------------------------------------------------------------------
# Follows (~75) — deterministic assignment based on index
# ---------------------------------------------------------------------------
puts "Seeding follows..."

users.each_with_index do |user, i|
  # Each user follows 1-2 orgs, determined by their index
  count = 1 + (i % 2)
  count.times do |j|
    org = organizations[(i * 2 + j * 5) % organizations.size]
    Follow.find_or_create_by!(user: user, organization: org)
  end
end

puts "  #{Follow.count} follows"

puts "\nSeeding complete!"
puts "  Organizations: #{Organization.count}"
puts "  Users: #{User.count}"
puts "  Events: #{Event.count}"
puts "  Attendances: #{Attendance.count}"
puts "  Follows: #{Follow.count}"
