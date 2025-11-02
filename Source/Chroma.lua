local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/asteroidlordfr/Chroma/refs/heads/main/Source/Rayfield.lua'))()

-- the variable (and function) warehouse

local ReplicaSignal = game:GetService("ReplicatedStorage"):WaitForChild("ReplicaRemoteEvents"):WaitForChild("Replica_ReplicaSignal")

local sendingAnswers = false
local randomizedSending = false
local delayTime = 1

local answers = {
"bow and arrow", "halberd double barreled wheeler gun", "titanium", "chromium", "rutherfordium", "influenza", "human immunodeficiency virus", 
"labrador retriever", "chocolate ice cream", "refrigerator handle", "gamingwithkev", "the diamond minecraft", "luxembourg", 
"equatorial guinea", "democratic republic of the congo", "eastern diamondback rattlesnake", "leopard", "lavender albino ball python", 
"orange", "magenta", "indigo", "wellington boots", "carbon dioxide", "copy and paste", "monster energy drink", "rockstar energy drink", 
"coloured pencils", "mechanical pencils", "graphical calculator", "pre winter", "hemidemisemicircle", "wednesday", "december", 
"lifestyle choices", "construction work", "laboratory technician", "handling and studying radioactive materials", "african buffalo", 
"rhinoceros", "bactrian camel", "brownheaded cowbird", "rubbish", "non biodegradable", "baby zombie villager", "coffee shop", 
"public transportation", "doctor office", "yellow", "the sheriff of nottingham", "sunflower yellow", "sonic the hedgehog", 
"super mario brothers", "baby princess rosalina", "hide and seek", "chocolate chip cookie dough ice cream", "breakfast", 
"midnight snack", "grandparents", "personal development professional", "bacon eggs and cheese burrito", "breakfast sandwhich", 
"rice cooker", "breakfast stand", "freddys frozen custard and steak burgers", "playing video games", "kristoff", "european fallow deer", 
"spongebob squarepants", "yellow orange", "september", "rudolph", "bashful", "warofthespanishsuccession", "multi surface cleaner", 
"rubber ducky", "electric toothbrush", "outdoor photography", "wheelchair basketball", "large intestine", "foreheads", "occipital bone", 
"office building", "school cafeteria", "doctor’s office", "neptune", "silver", "sleeping beauty", "breaded chicken breast", 
"salad dressing", "thousand island dressing", "traffic enforcer", "parking enforcement officer", "american cheese", 
"caramellized onion", "wisdom tooth", "traffic cones", "emergency response vehicles", "emergency medical service", "take photographs", 
"watermelon", "drinking", "hot air balloon", "atmospheric pollution levels", "noise canceling headphones", "kitchen knife", 
"japanese cleaver", "broken glass bottle", "play sports", "coloring pencils", "having conversation with friends", "vegetables", 
"climbing frames", "construction equipment", "rocking chair", "outdoor patio furniture", "motorcycle saddle", "underestimated", 
"anti deodorant shampoo", "global positioning system devices", "coconut tree", "continental fault lines", "watermelon juice", 
"mountain valley spring water", "doctor heinz doofenshmirtz", "running shoes", "leaf blower", "fertilizer spreader", "american football", 
"extensions", "mountains", "guangdong oppo mobile telecommunications corporation limited", "mathematics textbook", "driver’s license", 
"emergency contact list", "callyoursiblings", "milky way galaxy", "school identification", "northern lights", "classmates", 
"athletics dancing competition", "old appliances", "hide and seek", "pretending to be asleep", "emergency kit", "radio frequency identification system", 
"whiteboard", "projection screen", "task organization board", "princess rosalina", "duckling", "reinforce", "milkshake", "gravity", 
"sunlight", "religious figure", "johnson and johnson", "pulled pork", "fried chicken", "instagram", "facebook messenger", 
"united states of america", "clarabelle cow", "mickeys friends from toon town online", "united kingdom of great britain and northern ireland", 
"the federated states of micronesia", "super nintendo entertainment system", "playstation vita", "gooseberries", "golden delicious apples", 
"granny smith apples", "medium length", "cascading waterfall braid hairstyles", "haunted house", "mold infested house", "roasted green pepper", 
"snakes and ladders", "monopoly eightieth anniversary edition", "dungeons and dragons", "saint patrick’s day", "andesine feldspar", 
"mount saint helens emerald", "getting chased by police", "laser tag", "shadow the hedgehog", "medical emergency", "australian flat oyster", 
"blowfish malibu", "veggie burger", "poultry", "sunflowers seeds", "lily of the valley", "five pin bowling", "free style snowboarding", 
"mountainboarding", "freestyle snowboarding", "keyboard", "monkey puzzle tree", "horseback riding", "tactical operations", 
"caecilians", "indonesian speckled carpetshark", "sweater", "wool sweater", "construction worker", "starbucks unicorn frapuccino", 
"magic potions", "enchanted forest creatures", "fireplace", "burning charcoal", "strawberries", "segmented and peeled mandarin oranges", 
"flag ceremony", "playground equipment", "slenderman", "the sound of footsteps approaching", "hippopotamus", "sabertoothed cat", 
"apply deodorant", "close their eyes", "exercising", "playing instrument", "mosquito bites", "flashlight", "bioluminescent organisms", 
"air conditioner", "smartphone", "christmas ornament", "wireless radio", "restaurant background music", "noise referring headphones", 
"flat screen television", "sleeping bag", "inflatable matress", "check outfit", "apply skincare products", 
"interactive virtual reality headset", "rowley jefferson", "real estate", "travelling experience", "thanksgiving", "valentines day", 
"hot air balloon", "cocktail stick", "clean the house", "grocery shopping", "survive and kill the killers in area 51", 
"undertale test place reborn", "flee the facility", "electronic word clock", "valentine’s day", "national ugly christmas sweater day", 
"art gallery", "private swimming pool", "university swimming pools", "professional baseball", "straighten", "getting hair treatment", 
"andorra la vella", "incomprehension", "popular video game characters", "the legend of zelda breath of the wild", "roller skates", 
"wheelchair accessible seating", "relationship", "insulated concrete forms", "macadamia nuts", "watermelon seed", "beach umbrella", 
"cuttlefish bones", "phone charger", "beach blanket", "glasses", "accessories", "feminine", "electricity", "opportunities", 
"noisy nightclubs", "construction", "sleepwalk", "experience restless leg syndrome", "grandfather clock", "nothing", "condensed milk", 
"historical site", "museum of ancient civilizations", "psychiatrist", "human resources representative", "ultrasound", "competition bound", 
"children’s museums", "cumulonimbus", "finger", "electric current", "bangladesh", "rooster", "chicken", "middle distance", 
"construction worker", "tactical operations", "ping pong ball", "detective eathan", "inaccessible island rail", "doramad radioactive toothpaste", 
"slot machine", "monica geller", "joey tribbiani", "federated states of micronesia", "united arab emirates", "netherlands", 
"united states of america", "democratic republic of congo", "mountain rescue", "south america", "bangladeshi martial arts", "hedgehogs", 
"bearded dragon", "brazilian salmon pink bird eating tarantula", "peanut butter", "artificial food coloring", "social security card", 
"micropachycephalosaurus", "pterodactyl bronchiosaurus", "rastafarianism", "hephaestus", "hufflepuff", "phone case", "pop socket", 
"kitchen accessories", "progressive rock", "electric acoustic guitar", "datu puti vinegar", "thousand island dressing", 
"london bridge is falling down", "fletchinder", "underwater volcanic eruption", "north atlantic ocean", "gluttony", 
"mississippimissouri", "coconut water", "expensive skincare and beauty products", "flatscreen television", "lamborghini", 
"harrison schmitt", "monster university", "buzz lightyear of star command the adventure begins", "amusement park", 
"department of motor vehicles", "transportation stops", "uefa european football championship", "offensive tackle", "outside linebacker", 
"travel counselor", "town and city", "attacking midfielder", "videographers", "snow white and the seven dwarves", 
"the chronicles of narnia the lion the witch and the wardrobe", "take pictures", "tumbleweeds", "groundhog", "christmas party", 
"flat screen television", "presidential election", "uefa european football championships", "chowhound", "chocolate covered biscuits in milk chocolate", 
"albat rosses", "smartphone", "drivers license", "peanut butter", "phillips screwdriver", "plastic packaging", "texasholdem", 
"harry potter trading card game", "underwater ice hockey", "sagittarius", "canis major", "breast stroke", "elementary backstroke", 
"fairy godmother", "qualifications", "prescription pad", "electroencephalography machine", "north american black bear", "mozzarella cheese", 
"gorgonzola cheese", "adrenaline", "liquefied petroleum gas", "migraines", "caffeine withdrawal headache", "blackjack", 
"employment practices liability", "reinforced steel", "thermal pollution", "particulate matter pollution", "sunflower", 
"diamondback rattlesnake", "protobothrops flavoviridis", "teleportation", "public transportation", "sandalwood", 
"brazilian mahogany", "eastern black walnut", "decomposition", "belousov zhabotinsky reaction", "nonverbal communication", "arkansas", 
"first person shooter", "massively multiplayer online role playing game", "social media", "sign language", "amphibians", "harry potter", 
"employment practices liability", "scooby doo", "norville shaggy rogers", "mucosa associated lymphatic tissue", "australian rules football", 
"widowmaker", "sunflower seeds", "underground waterfalls", "baby princess rosalina", "clotheshorse", "giant huntsman spider"
}

local function sendAllAnswers()
    for _, answer in ipairs(answers) do
        local args = { [1] = 2, [2] = "Answer", [3] = answer }
        ReplicaSignal:FireServer(unpack(args))
    end
end

-- no more warehouse

local Window = Rayfield:CreateWindow({
   Name = "Chroma",
   LoadingTitle = "Open-sourced Roblox universal cheat.",
   LoadingSubtitle = "Licensed under GPLv3",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, 
      FileName = "Chroma"
   },
   KeySystem = false, 
})

local Voice = Window:CreateTab("VC")
Voice:CreateButton({
      Name = "Unsuspend VC",
      Info = "If VC banned, unsuspends your voice chat.",
      Callback = function()
         game:GetService("VoiceChatService"):joinVoice()
      end,
})

local Credits = Window:CreateTab("Credits") 
Credits:CreateButton({
   Name = "AsteroidLord",
   Info = "Owner and Developer of Chroma", 
   Callback = function()
   end,
})

local Games = Window:CreateTab("Games") 
Games:AddSection({
      Name = "Type or Die",
})

Games:CreateToggle({
    Name = "Auto Answer",
    CurrentValue = false,
    Callback = function(state)
        sendingAnswers = state
        task.spawn(function()
            while sendingAnswers do
                sendAllAnswers()
                task.wait(delayTime)
            end
        end)
    end
})

Games:CreateButton({
   Name = "Answer",
   Info = "Sends a answer", 
   Callback = function()
         sendAllAnswers()
   end,
})
