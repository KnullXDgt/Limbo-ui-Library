--[[
    Limbo Hub Clean API Template (Production Skeleton)
    Aligned with Fish It 2.0.7 Features & Structure
    Full Validation + Clean OOP Wrapper + Auto Config Save
]]

local GAME_NAME      = "Fish It"
local VERSION        = "2.0.7"
local LIMBO_TAG      = "[LIMBO HUB]"
local DISCORD_INVITE = "https://discord.gg/GtDHsXGJ4g"

local ALL_FISH_NAMES = {
    "1x1x1x1 Comet Shark",
    "1x1x1x1 Shark",
    "Abyr Squid",
    "Abyshorn Fish",
    "Abyss Seahorse",
    "Abyssal Maw Angler",
    "Abyssal Whisker",
    "Abyssjaw",
    "Aetherhorn Charger",
    "Alien Dumbo",
    "Alien Guppy",
    "Alienhead Squid",
    "Alligator Snapper",
    "Amethyst Snapper",
    "Ancient Arapaima",
    "Ancient Crawler",
    "Ancient Lochness Monster",
    "Ancient Magma Whale",
    "Ancient Pufferfish",
    "Ancient Relic Crocodile",
    "Ancient Squid",
    "Ancient Whale",
    "Angelic Highschool Walrus",
    "Angler Fish",
    "Angry Rocky",
    "Angrylion Fish",
    "Antique Cup",
    "Antique Watch",
    "Aquaceratops",
    "Armor Catfish",
    "Arowana",
    "Ash Basslet",
    "Ashen Kingfish",
    "Ashen Seahorse",
    "Asteroid",
    "Asteroid Fish",
    "Astra Damsel",
    "Astral Kelpie",
    "Astralune",
    "Astrelle",
    "Astronaut Manatee",
    "Aurelion",
    "Aurora Butterfly Fish",
    "Aurora Grouper",
    "Aurora Manatee",
    "Aurora Narwhal",
    "Aurora Starfish",
    "Axolotl",
    "Azul Crab",
    "Azure Damsel",
    "Azure Reef Crab",
    "Baby Fiery Shark",
    "Baby Maya Fish",
    "Baby Pumpkin Shark",
    "Baby Shrimp",
    "Ballina Angelfish",
    "Balloon Shrimp",
    "Banded Butterfly",
    "Bandit Angelfish",
    "Bandit Octopus",
    "Banditfish",
    "Barracuda Fish",
    "Basalt Ghost Shark",
    "Beach Ball",
    "Beanie Leedsicheye",
    "Bioluminescent Manta Ray",
    "Biolumiscent Octopus",
    "Black Tide Shrimp",
    "Blackcap Basslet",
    "Blackhole Sea Dragon",
    "Bleekers Damsel",
    "Blob Fish",
    "Blob Shark",
    "Blobby Shieldfish",
    "Block Fish",
    "Blockmine Fish",
    "Blocky Lochness Monster",
    "Blocky Octopus",
    "Bloodborn Ravanger",
    "Bloodlight Anglerfish",
    "Bloodmoon Whale",
    "Blossom Jelly",
    "Blue Lobster",
    "Blue Moonfish",
    "Blue Sea Dragon",
    "Blue Shell Crab",
    "Blue-Banded Goby",
    "Blueface Sunfish",
    "Bluefin Eel",
    "Blueflame Ray",
    "Bluehood Nautilus",
    "Blumato Clownfish",
    "Blushfin",
    "Blushwave",
    "Boa Angelfish",
    "Boar Fish",
    "Bodyswap Jellyfish",
    "Boltback Fish",
    "Boltfin Coelacanth",
    "Bone Whale",
    "Boned Arrowhead Fish",
    "Bonemaw Tyrant",
    "Boney Eel",
    "Bowtie Blobby",
    "Brighteyes Guppy",
    "Brimstone Catfish",
    "Brinehead Fish",
    "Broken Heart Nessie",
    "Bucket Fish",
    "Builderman Guppy",
    "Buildersclub Fish",
    "Bumblebee Grouper",
    "Business Crab",
    "Cabana Carp",
    "Cabana-cuda",
    "Cactus Dorey",
    "Cactus Fish",
    "Cactus Piranha",
    "Cactus Pufferfish",
    "Cactus Spearfish",
    "Cactus Turtle",
    "Caeruleum Razerback",
    "Cake Turtle",
    "Candy Butterfly",
    "Candy Corn Eel",
    "Candycane Lobster",
    "Cantelope Puffer",
    "Captain Pufferfish",
    "Carrot Eel",
    "Carrot Fish",
    "Carrotfish",
    "Catfish",
    "Caustic Maw",
    "Cavern Dweller",
    "Cavern Toad",
    "Cerulean Dragon",
    "Cerulean Lurker",
    "Charged Isopod",
    "Charmed Tang",
    "Cherry Spearfish",
    "Chill Santa Fish",
    "Choco Shark",
    "Chocolate Bunny Fish",
    "Chocolate Fish",
    "Christmas Light Carp",
    "Christmas Penguin",
    "Christmas Wreath Fish",
    "Christmastree Longnose",
    "Chrome Tuna",
    "CinderSail",
    "Cindering Reefback",
    "Cinderplate Coelacanth",
    "Classic Angler",
    "Classic Bass",
    "Classic Dorhey Tang",
    "Classic Dumbo",
    "Classic Glass Octopus",
    "Classic Goldfish",
    "Classic Piranha",
    "Classic UFO Turtle",
    "Classy Snowfish",
    "Clay Reef Fish",
    "Cloudswimmer",
    "Cloudy Clown Fish",
    "Cloudy Seal",
    "Clownfish",
    "Coal Tang",
    "Coconut Dotty",
    "Cold Blue Vinny",
    "Colossal Shipwreck Crab",
    "Comet Stone ",
    "Comet Toad",
    "Conch Shell",
    "Coney Fish",
    "Conspi Angelfish",
    "Constellation Kittyfish",
    "Copperband Butterfly",
    "Coral",
    "Coral Manta Ray",
    "Coral Reaper",
    "Coral Whale",
    "Corazon Damsel",
    "Cosmic Bass",
    "Cosmic Blobfish",
    "Cosmic Hammerhead Shark",
    "Cosmic Jellyfish",
    "Cosmic Mutant Shark",
    "Cosmic Seahorse",
    "Cosmic Seastar",
    "Cosmic Tailfish",
    "Cousin Tentacles",
    "Cow Clownfish",
    "Cow Moonfish",
    "Cow Narwhale",
    "Cowboy Octopus",
    "Cozy Carp",
    "Cozy Narwhal Plushie",
    "Cracked Egg Fish",
    "Cracked Egg Jellyfish",
    "Crater Fish",
    "Crescentfin",
    "Crimson Dreadtusk",
    "Crimson Octopus",
    "Crimson Piranha",
    "Crimson Stream Eel",
    "Crocodile",
    "Crown",
    "Crowned Hadal Coffinfish",
    "Cryoclaw Lobster",
    "Cryoshade Glider",
    "Crystal Crab",
    "Crystal Goliath",
    "Crystal Lancer",
    "Crystal Octopus",
    "Crystal Oni Fish",
    "Crystal Pufferfish",
    "Crystal Rockfish",
    "Crystal Salamander",
    "Crystalized Crab",
    "Crystalline Behemoth",
    "Cupid Octopus",
    "Curious Garfish",
    "Cursed Kraken",
    "Cute Dumbo",
    "Cute Octopus",
    "Cutlass Runner",
    "Cutsie Fish",
    "Cypress Ratua",
    "Dark Eel",
    "Dark Megalodon",
    "Dark Pumpkin Appafish",
    "Dark Tentacle",
    "Darwin Clownfish",
    "Dead Fish",
    "Dead Scary Clownfish",
    "Dead Spooky Koi Fish",
    "Dead Zombie Shark",
    "Deep Sea Crab",
    "Deep Sea Diving Helmet",
    "Deep Sea Eel",
    "Deepblue Lion Fish",
    "Deepsea Dweller",
    "Deepsea Flying Fish",
    "Deepsea Leech",
    "Deepsea Monster Axolotl",
    "Deepsea Piranha",
    "Depthseeker Ray",
    "Desert Frog",
    "Desert Snail",
    "Desert Tailfish",
    "Diamond Ring",
    "Disco Frogalloon",
    "Disco Party Puffer",
    "Dogfish",
    "Domino Damsel",
    "Doober Fish",
    "Dorhey Tang",
    "Dotted Stingray",
    "Dream Jelly",
    "Drip Walrus",
    "Drippy Retro Octopus",
    "Drippy Tucanare",
    "Duckling Fish",
    "Dusty Falunder Fish",
    "Dusty Horseshoe Crab",
    "ELEMENTAL HYDRA",
    "Easter Blobfish",
    "Easter Bunny Fish",
    "Easter Duckling",
    "Easter Eel",
    "Easter Flower Fish",
    "Easter Leaf Fish",
    "Easter Pufferfish",
    "Easter Snail",
    "Easter Swimmer",
    "Eerie Fish",
    "Eerie Shark",
    "ElRetro Gran Maja",
    "Electric Eel",
    "Elegant Eel",
    "Elemental Tempestray",
    "Elf Guppy",
    "Elpirate Gran Maja",
    "Elshark Gran Maja",
    "Emberback Spider Crab",
    "Emberfin Pike",
    "Emerald Herring",
    "Emerald Winter Whale",
    "Enchanted Angelfish",
    "Enchanted Turtle",
    "Everblaze",
    "Everbloom",
    "Expensive Chain",
    "Fade Tang",
    "Fangtooth",
    "Festive Dolphin",
    "Festive Goby",
    "Festive Pufferfish",
    "Festive Salmon",
    "Finny Present",
    "Fire Goby",
    "Firecoal Damsel",
    "Fish Fossil",
    "Flame Angelfish",
    "Flame Tyrant",
    "Flarebait Angler",
    "Flashfin Swordfish",
    "Flat Fish",
    "Flatheaded Whale Shark",
    "Floaty Damsel",
    "Flowery Fish",
    "Fluorivane",
    "Flying Cavern Fish",
    "Flying Fish",
    "Flying Hearts",
    "Flying Manta",
    "Football",
    "Forever Forehead",
    "Fossilized Shark",
    "Foxtrot Koanfish",
    "Frankenstein Longsnapper",
    "Freshwater Piranha",
    "Friendly Lobster",
    "Frog",
    "Frost Crab",
    "Frostbite Bluefinn",
    "Frostbite Leviathan",
    "Frostborn Cataclypse",
    "Frostborn Shark",
    "Frostbound Oracle",
    "Frostbreaker Whale",
    "Frostfin",
    "Frostglass Mako Shark",
    "Frostglow Globe Jelly",
    "Frostmoon Whale",
    "Frostshell Turtle",
    "Frostspine Hake",
    "Frostveil Ray",
    "Frostwhisker",
    "Frozen ClownFish",
    "Frozen Tang",
    "Frozen Tundra",
    "Fulgur Naso",
    "Galactic Moonfish",
    "Gar Fish",
    "Geode Drifter",
    "Geodeback Sea Turtle",
    "Ghastly Crab",
    "Ghastly Hermit Crab",
    "Ghost Shark",
    "Ghost Spiralfish",
    "Ghost Whitefin",
    "Ghost Worm Fish",
    "Ghostlight Oarfish",
    "Giant Squid",
    "Giftback Turtle",
    "Gilded Giant Isopod",
    "Gingerbread Clownfish",
    "Gingerbread Crab",
    "Gingerbread Fish",
    "Gingerbread Fish Plushie",
    "Gingerbread Ray",
    "Gingerbread Shark",
    "Gingerbread Starfish",
    "Gingerbread Tang",
    "Gingerbread Turtle",
    "Glacial Fangtooth",
    "Glacial Serpent",
    "Glacier Bass",
    "Glacierback Sea Turtle",
    "Glacierfin Snapper",
    "Gladiator Shark",
    "Glass Lancetfish",
    "Glasswing Devil Ray",
    "Glitter Bunnyfish",
    "Glowcap Hermit",
    "Glowspore Toad",
    "Glowstone Seaslug",
    "Goblin Shark",
    "Gold",
    "Gold Bass",
    "Golden Drill Fish",
    "Goldmask Tetra",
    "Goliath Tiger",
    "Goofy Santa Fish",
    "Great Christmas Whale",
    "Great Whale",
    "Green Gillfish",
    "Greenbee Grouper",
    "Grumpy Angler",
    "Guest Guppy",
    "Guest Pufferfish",
    "Gumball Whale",
    "Gummy Fish",
    "Guppyfish",
    "Guttenfang",
    "Halo Fish",
    "Hammerhead Mummy",
    "Hammerhead Shark",
    "Happy Sunfish",
    "Hawks Turtle",
    "Heart Dolphin",
    "Heart Octopus",
    "Heart Walrus",
    "Helios Wrasse",
    "Hermit Crab",
    "Herring Fish",
    "Hibiscus Chromis",
    "Holiday Angler Plushie",
    "Holiday Guppy Plushie",
    "Holiday Turtle Plushie",
    "Hoola Hoop Bass",
    "Horseshoe Crab",
    "Hybodus Shark",
    "Hyper Eel",
    "Hyperjelly",
    "Icebreaker Whale",
    "Icecap Runner",
    "Icefang Angler",
    "Icey Pufferfish",
    "Icy Depths Koi",
    "Icy Fish",
    "Icy Swordfish",
    "Iridesca",
    "Iron Domefin",
    "Jellyfin",
    "Jellyfish",
    "Jennifer Dottyback",
    "Jester Pufferfish",
    "Jewel Tang",
    "Jingle Bells Fish",
    "Jinglefin",
    "Jolly Crab",
    "Kau Cardinal",
    "Ketupat Fish",
    "Ketupat Lobster",
    "Ketupat Sea Turtle",
    "Ketupat Slug",
    "Ketupat Swordfish",
    "Ketupat Tailfish",
    "Ketupat Whale",
    "King Crab",
    "King Frog",
    "King Jelly",
    "King Mackerel",
    "King Swirl Pufferfish",
    "Komodo Dragon",
    "Korblox Shark",
    "Korean Angelfish",
    "Krampus Shark",
    "Lady Luminelle",
    "Lake Sturgeon",
    "Lava Butterfly",
    "Lava Lamp Jelly",
    "Lava Salmon",
    "Lava Sharpshead",
    "Lava Sharptooth",
    "Lava Tailfish",
    "Lavafin Tuna",
    "Leaf Fin",
    "Lettuce",
    "Leviathan",
    "Liar Nose Fish",
    "Lifeguard Longfish",
    "Lightning Grouper",
    "Lined Cardinal Fish",
    "Linked Sword Fish",
    "Lion Fish",
    "Lobster",
    "Lochness Monster",
    "Loggerhead Turtle",
    "Longboard Boxfish",
    "Longnose Butterfly",
    "Longspine Dory",
    "Loungehorn Cowfish",
    "Love Nessie",
    "Loving Shark",
    "Loving Tang",
    "Lovtopus",
    "Lumenray",
    "Lumilotl",
    "Lumina Stinger",
    "Luminous Fish",
    "Luminous Thornyhead",
    "Lunar Crescent Fish",
    "Lunar Koi",
    "MACHODON",
    "Magic Tang",
    "Magma Crab",
    "Magma Eel",
    "Magma Goby",
    "Magma Piranha",
    "Magma Ptychodus",
    "Magma Pufferfish",
    "Magma Shark",
    "Magma Smeltfish",
    "Magma Swordfish",
    "Magma Tail Fish",
    "Magma Tuna",
    "Magmajaw",
    "Magmaquill Pufferfish",
    "Mammoth Appafish",
    "Manoai Statue Fish",
    "Manta Ray",
    "Maroon Butterfly",
    "Masked Angelfish",
    "Matrix Fish",
    "Maze Angelfish",
    "Megalodon",
    "Metal",
    "Midnight Stars Squid",
    "Mistle Toe Fish",
    "Mistle Toe Seahorse",
    "Mistletoe Damsel",
    "Misty Sword Fish",
    "Molten Parrotfish",
    "Monk Fish",
    "Monster Shark",
    "Moonfish",
    "Moonlit Beakfish",
    "Moonribbon",
    "Moonwake Ray",
    "Moorish Idol",
    "Mosasaur Shark",
    "Mossy Fishlet",
    "Mossy Vampire Fish",
    "Mr Money Bags",
    "Mr. Bubbles",
    "Mutant Runic Koi",
    "Narwhal",
    "Nebble Fish",
    "Neon Tang",
    "Neonite Fish",
    "New Years Axolotl",
    "New Years Clownfish",
    "New Years Goby",
    "New Years Grouper",
    "New Years Jellyfish",
    "New Years Lobster",
    "New Years Pufferfish",
    "New Years Seahorse",
    "New Years Whale Shark",
    "Night Glider Fish",
    "Nine Tailed Fish",
    "Northfin Helper",
    "Nutcracker Ray",
    "OG Snail",
    "OVERLORD HYDRA",
    "Obsidian Prawn",
    "Offshore Herald",
    "Old Boot",
    "Orange Basslet",
    "Orange Octopus",
    "Orange Striped Squid",
    "Orangy Goby",
    "Orca",
    "Ornament Fish",
    "Outlaw Seahorse",
    "Outrageous Celebrity Fish",
    "Pailatee",
    "Painted Egg Fish",
    "Panther Eel",
    "Panther Grouper",
    "Parasitic Mutant Shark",
    "Parrot Blopfish",
    "Parrot Fish",
    "Pastel Easter Sawfish",
    "Pastel Egg Pufferfish",
    "Pastel Guppie",
    "Pastel Rainbow Sardine",
    "Patriot Tang",
    "Peach Bubbler",
    "Peach Clownfish",
    "Peach Tailfish",
    "Peach Tuna",
    "Pearl",
    "Pelagon",
    "Peppermint Fish",
    "Peppermint Spike",
    "Petalfish",
    "Phantom Goblin Shark",
    "Phosphor Jellyfish",
    "Pilot Fish",
    "Pinata Crab",
    "Pinata Squid",
    "Pink Crystal Eel",
    "Pink Dolphin",
    "Pink Smith Damsel",
    "Pirate Blue Lobster",
    "Pirate Dreadfin",
    "Pirate Megalodon",
    "Pirate Sailfish",
    "Pirate Starfish",
    "Pizza Slice",
    "Plasma Serpent",
    "Plasma Shark",
    "Poolside Nautilus",
    "Primal Axolotl",
    "Primal Lobster",
    "Primordial Octopus",
    "Princess Pufferfish",
    "Prismari",
    "Prismatic Nudibranch",
    "Prismy Seahorse",
    "Prison Lionfish",
    "Prisoner Fish",
    "Pufferfish",
    "Pumpkin Angler Fish",
    "Pumpkin Butterfly Fish",
    "Pumpkin Carved Shark",
    "Pumpkin Hermit Crab",
    "Pumpkin Jellyfish",
    "Pumpkin Ray",
    "Pumpkin StoneTurtle",
    "Purp Blisfish",
    "Purple Razorback",
    "Purple Retro Squid",
    "Pygmy Goby",
    "Pyroclast Stonefish",
    "Pyrocoil",
    "Queen Crab",
    "Racoon Butterfly Fish",
    "Radiant Catfish",
    "Radiant Dolphin",
    "Radioactive Longfish",
    "Ragnarex",
    "Rainbow Comet Shark",
    "Rainy Dumbo",
    "Rainy Koi",
    "Red Fedora Fish",
    "Red Goatfish",
    "Red Rose",
    "Red Snapper",
    "Red Urchin",
    "Reef Bluefish",
    "Reef Chromis",
    "Reef Minnow",
    "Reindeer Fish",
    "Reindeer Guppy",
    "Reindeer Shark",
    "Retro Burger Fish",
    "Retro Crab",
    "Retro Crocodile",
    "Retro Slitherfish",
    "Retro Viper Angler",
    "Riftborn Arowana",
    "Riftfin",
    "Ripplefin",
    "Rippleveil",
    "Robot Kraken",
    "Rockfish",
    "Rockform Cardinal",
    "Rocky Scorpion",
    "Rose Bouquet",
    "Rose Swordfish",
    "Rubber Ducky",
    "Ruby",
    "Runebound Crocodile",
    "Runic Abyssal Shark",
    "Runic Axolotl",
    "Runic Grouper",
    "Runic Lobster",
    "Runic Sea Crustacean",
    "Runic Squid",
    "Runic Wispeye",
    "S.W.A.T Soldier Fish",
    "SPFin Shark",
    "Sacred Guardian Squid",
    "Sail Fish",
    "Sail Tang",
    "Sailor Crab",
    "Sailor's Bluefish",
    "Salmon",
    "Sand Eel",
    "Santa Guppy",
    "Sapphire Octopus",
    "Sapphyra",
    "Saturnpuff",
    "Saw Fish",
    "Scaly Parrot Fish",
    "Scare",
    "Scarrock Mudfish",
    "Scary Clownfish",
    "Scissortail Dartfish",
    "Scorching Veinmaw",
    "Scoria Stone Crab",
    "Sea Anemone",
    "Sea Crustacean",
    "Sea Eater",
    "Sea Shell",
    "Sea Urchin",
    "Seahorse Fish",
    "Seaweed Pufferfish",
    "Sharp One",
    "Shedletsky Guppy",
    "Sheepshead Fish",
    "Sheriff Badge",
    "Sheriff Lobster",
    "Sheriff Sawfish",
    "Shrimp Goby",
    "Silly Easter Duck",
    "Silver Skydart",
    "Silver Tuna",
    "Skeleton Angler Fish",
    "Skeleton Fish",
    "Skeleton Narwhal",
    "Skunk Tilefish",
    "Slender Lobster",
    "Slipstream Fish",
    "Slurpfish Chromis",
    "Smarty Mcfish",
    "Snappy Tooth Fish",
    "Snorkel Sturgeon",
    "Snowflake Puffer Fish",
    "Solar Koi",
    "Solarflare Koi",
    "Solwyrm",
    "Sona Fin Fish",
    "Sophisticated Angler",
    "Sparkly Eel",
    "Spear Guardian",
    "Specked Butterfly",
    "Spectral Chimera",
    "Spine Eel",
    "Spooky Koi Fish",
    "Spooky Peafish",
    "Sporeback Sturgeon",
    "Spotted Grouper",
    "Spotted Lantern Fish",
    "Sprinkle Fish",
    "Sprinkle Wrinkfish",
    "Star Snail",
    "Starback Angler",
    "Starback Catfish",
    "Starback Tang",
    "Starbell Angler",
    "Starbloom Jelly",
    "Starbloom Manta",
    "Starfish",
    "Starglass Guardian",
    "Starjam Tang",
    "Starlight Crab",
    "Starlight Manta Ray",
    "Starlight Scampi",
    "Starry Night Shark",
    "Starry Night Whale",
    "Starry Nights Sawfish",
    "Steampunk Diver",
    "Steelfin Marlin",
    "Stonebelly Fish",
    "Stormfrill Axolotl",
    "Stormshell Brute",
    "Stormy Dumbo",
    "Strawberry Choc Megalodon",
    "Strawberry Dotty",
    "Strawberry Fish",
    "Strawberry Orca",
    "Strawberry Pufferfish",
    "Strawberry Seahorse",
    "Striped Beakfish",
    "Striped Retro Fish",
    "Stripped Straw Hat Fish",
    "Strippled Seahorse",
    "Studded Dolphin",
    "Studded Jellyfish",
    "Sunband Fish",
    "Sunbather Manta Ray",
    "Sunfang Nautilus",
    "Sunglass Snapper",
    "Sunken Hadalith",
    "Sunny Beakfish",
    "Sunset Shrimp",
    "Sunstripe Reef Fish",
    "Supply Barrel",
    "Surfboard Cardinal",
    "Sushi Cardinal",
    "Swirl Crab Cake",
    "Swordfish",
    "Synodontis",
    "Taco Fish",
    "Talon Serpent",
    "Talon's Blob Fish",
    "Tempest Stonefish",
    "Temple Parrotfish",
    "Temple Spokes Tuna",
    "Teslacoil Octopus",
    "Thin Armor Shark",
    "Thinkler Fish",
    "Thresher Shark",
    "Thunder Clam",
    "Thunder Manta Ray",
    "Thunder Squid",
    "Thundercrest Ray",
    "Thunderhead Cuttlefish",
    "Thunderstorm Jelly",
    "Thunderzilla",
    "Tidecrest Dolphin",
    "Tiny Retro Moonfish",
    "Tomato",
    "Toothy Fish",
    "Tortilla",
    "Tourist Tang",
    "Toxic Jellyfish",
    "Traffic Cone Fish",
    "Tralalero Tralala",
    "Trav Grupper",
    "Treasure Crab",
    "Tree Frog",
    "Tree Horse",
    "Trench Gulpe",
    "Trench Warden",
    "Tricolore Butterfly",
    "Tropical Doober Fish",
    "Tumbleweed",
    "Tumbleweed Eel",
    "Turboclub Manfish",
    "Turqoi Backfin",
    "Twinkle Star Jelly",
    "Twinkleclaw",
    "Two-Headed Shark",
    "Unicorn Tang",
    "Unknown Fish",
    "Valentine Eel",
    "Valentine Lion Fish",
    "Valentine Pearl Fish",
    "Vampire Squid",
    "Velastra",
    "Vineback Pike",
    "Vintage Blue Tang",
    "Vintage Damsel",
    "Violet Divafish",
    "Violet Frog",
    "Viperangler Fish",
    "Viperfish",
    "Viridis Lurker",
    "Void Eel",
    "Voidlight Deepfish",
    "Volcanic Basslet",
    "Volsail Tang",
    "Wahoo",
    "Walrus Bride",
    "Walrus Gentlemen",
    "Watanabei Angelfish",
    "Water Snake",
    "Waveback Fish",
    "White Clownfish",
    "White Tang",
    "Wild Serpent",
    "Wild West Crab",
    "Wing Parrotfish",
    "Winged Seahorse",
    "Winter Frost Shark",
    "Winter Sweater Redfin",
    "Wintermaw Wolfeel",
    "Wintertusk Mammofin",
    "Witch Fish",
    "Witch Koi Fish",
    "Wizard Stingray",
    "Worm Fish",
    "Wraithfin Abyssal",
    "Yello Damselfish",
    "Yellow Spinefin",
    "Yellowfin Tuna",
    "Yellowstate Angelfish",
    "Zapfin Fish",
    "Zapfish",
    "Zebra Snakehead",
    "Zebra Striped Fish",
    "Zombie Megalodon",
    "Zombie Shark",
    "Zoster Butterfly",
}


-- 1. Anti Multi-Instance
if getgenv().LimboHub and type(getgenv().LimboHub.Destroy) == "function" then
    pcall(function() getgenv().LimboHub:Destroy() end)
end

-- 2. Official Limbo Hub Authentication / Validation
local LIMBO_BASE_URL = "https://limbohub.my.id"
local LIMBO_VERIFY_ENDPOINT = LIMBO_BASE_URL .. "/api/loader/adapter-verify"
local LIMBO_SESSION_ENDPOINT = LIMBO_BASE_URL .. "/api/loader/session"
local LIMBO_VALIDATE_ENDPOINT = LIMBO_BASE_URL .. "/api/loader/validate"
local LIMBO_HEARTBEAT_ENDPOINT = LIMBO_BASE_URL .. "/api/loader/heartbeat"
local LIMBO_GET_KEY_URL = LIMBO_BASE_URL .. "/get-key"
local LIMBO_TAG = "[LIMBO HUB]"

local LimboPlayers = game:GetService("Players")
local LimboHttpService = game:GetService("HttpService")
local RbxAnalytics = game:FindService("RbxAnalyticsService")
local LimboAccessScope = (getgenv and getgenv()) or _G
LimboAccessScope.__LIMBO_ACCESS_KICK = false

local function limboStop(reason)
	local player = LimboPlayers.LocalPlayer
	warn(LIMBO_TAG .. " " .. tostring(reason))
	if player then
		LimboAccessScope.__LIMBO_ACCESS_KICK = true
		player:Kick("\n" .. LIMBO_TAG .. "\n\n" .. tostring(reason) .. "\n")
	end
	error(LIMBO_TAG .. " access denied", 0)
end

local function limboCoerceBody(value, depth)
	if type(value) == "string" then
		return value
	end
	if type(value) ~= "table" or (depth or 0) > 10 then
		return nil
	end
	local nextDepth = (depth or 0) + 1
	for _, field in ipairs({ "Body", "body", "Data", "data", "Content", "content", "Result", "result" }) do
		local found = limboCoerceBody(value[field], nextDepth)
		if found then
			return found
		end
	end
	return limboCoerceBody(value[1], nextDepth)
end

local function limboRequestFunction()
	local scope = (getgenv and getgenv()) or _G
	local candidates = {
		rawget(scope, "request"),
		(syn and syn.request),
		(http and http.request),
		(fluxus and fluxus.request),
		rawget(scope, "http_request"),
	}
	for _, candidate in ipairs(candidates) do
		if type(candidate) == "function" then
			return candidate
		end
	end
	return nil
end

local function limboPostJson(url, payload)
	local send = limboRequestFunction()
	if not send then
		return nil, "Your executor does not expose an HTTP request function."
	end
	local ok, response = pcall(send, {
		Url = url,
		Method = "POST",
		Headers = { ["Content-Type"] = "application/json" },
		Body = LimboHttpService:JSONEncode(payload),
	})
	if not ok then
		return nil, "Network request failed: " .. tostring(response)
	end
	local body = limboCoerceBody(response)
	if type(body) ~= "string" or body == "" then
		return nil, "Empty response from the server."
	end
	local decoded
	local decodeOk = pcall(function()
		decoded = LimboHttpService:JSONDecode(body)
	end)
	if not decodeOk or type(decoded) ~= "table" then
		return nil, "Unexpected server response."
	end
	return decoded, nil
end

local function limboDeviceId()
	local parts = {}
	if RbxAnalytics then
		local ok, id = pcall(function()
			return RbxAnalytics:GetClientId()
		end)
		if ok and type(id) == "string" and #id > 0 then
			table.insert(parts, id)
		end
	end
	local scope = (getgenv and getgenv()) or _G
	for _, getter in ipairs({ "gethwid", "get_hwid" }) do
		local fn = rawget(scope, getter)
		if type(fn) == "function" then
			local ok, id = pcall(fn)
			if ok and type(id) == "string" and #id > 0 then
				table.insert(parts, id)
			end
		end
	end
	if #parts == 0 then
		table.insert(parts, tostring(LimboPlayers.LocalPlayer and LimboPlayers.LocalPlayer.UserId or 0))
		table.insert(parts, tostring(game.JobId))
	end
	local raw = table.concat(parts, ":"):gsub("[^%w%.%-%:_]", "")
	while #raw < 16 do
		raw = raw .. "0"
	end
	return raw:sub(1, 256)
end

local function limboKickMessage(response)
	local reason = tostring(response and response.reason or "")
	local message = tostring((response and response.error) or "Validation failed.")
	if reason == "slots_full" then
		return "ACCOUNT SLOTS FULL\n\n"
			.. tostring(response.slotsUsed or "?") .. " of " .. tostring(response.slotsTotal or "?") .. " slots are in use.\n\n"
			.. "Sign out of another account and wait 5 minutes, or buy more slots at " .. LIMBO_BASE_URL .. "/pricing"
	elseif reason == "device_mismatch" then
		return "This free key is locked to another device.\n\nGet a fresh key on this device at " .. LIMBO_BASE_URL .. "/get-key"
	elseif reason == "expired" then
		return message .. "\n\n" .. LIMBO_BASE_URL .. "/get-key"
	end
	return message
end

local function limboKeylessKickMessage(response, requestError)
	local reason = tostring(response and response.reason or "")
	if reason == "key_required" then
		return tostring((response and response.error) or "Keyless access has ended. A key is required.")
	elseif reason == "invalid_ticket" then
		return tostring((response and response.error) or "Your keyless session is invalid or expired. Rejoin or enter a key.")
	end
	return tostring(requestError or (response and response.error) or "Could not verify keyless access right now.")
end

local function limboShouldStopKeylessHeartbeat(response)
	local reason = tostring(response and response.reason or "")
	return reason == "key_required" or reason == "invalid_ticket"
end

local function limboAuthorize()
	local scope = (getgenv and getgenv()) or _G
	local player = LimboPlayers.LocalPlayer
	if not player then
		error(LIMBO_TAG .. " no LocalPlayer", 0)
	end
	local robloxUserId = string.format("%.0f", player.UserId)

	local handoff = scope.LimboHubSession
	if type(handoff) == "table" and type(handoff.ticket) == "string" and handoff.ticket ~= "" then
		local response, err = limboPostJson(LIMBO_VERIFY_ENDPOINT, {
			ticket = handoff.ticket,
			robloxUserId = robloxUserId,
		})
		if not response then
			limboStop("Could not verify your loader session.\n\n" .. tostring(err))
		end
		if not response.success then
			limboStop(limboKickMessage(response))
		end
		return {
			keyType = response.keyType,
			slotsUsed = response.slotsUsed,
			slotsTotal = response.slotsTotal,
			expiresAt = response.keyExpiresAt,
			ticket = handoff.ticket,
			needsKeyWindow = false,
			source = "loader",
			heartbeatTicket = response.keyType == "keyless"
				and handoff.heartbeatOwner ~= "loader"
				and handoff.ticket or nil,
		}
	end

	local config = scope.LimboConfig or scope.Config or {}
	local key = config.Key or config.key or config.ApiKey or config.APIKey
	if type(key) == "string" then
		key = key:gsub("%s", "")
		if key == "" or key == "empty" then
			key = nil
		end
	else
		key = nil
	end

	local response, err = limboPostJson(LIMBO_SESSION_ENDPOINT, {
		key = key,
		robloxUserId = robloxUserId,
		deviceId = limboDeviceId(),
	})
	if not response and not key then
		warn(LIMBO_TAG .. " Could not read access policy; showing the key window.")
		return {
			keyType = "none",
			needsKeyWindow = true,
			source = (type(handoff) == "table" and handoff.requiresKey) and "loader_guest" or "direct_guest",
		}
	elseif not response then
		limboStop("Could not reach Limbo Hub.\n\n" .. tostring(err))
	end
	if not response.success then
		limboStop(limboKickMessage(response))
	end
	if response.requiresKey or response.keyType == "none" then
		return { keyType = "none", needsKeyWindow = true, source = "direct_guest" }
	end

	scope.LimboHubSession = {
		ticket = response.adapterTicket,
		requiresKey = false,
		robloxUserId = robloxUserId,
		keyType = response.keyType,
		slotsUsed = response.slotsUsed,
		slotsTotal = response.slotsTotal,
		expiresAt = response.expiresAt,
		issuedAt = os.time(),
	}
	return {
		keyType = response.keyType,
		slotsUsed = response.slotsUsed,
		slotsTotal = response.slotsTotal,
		expiresAt = response.expiresAt,
		ticket = response.adapterTicket,
		needsKeyWindow = false,
		source = response.keyType == "keyless" and "server_keyless" or "direct",
		heartbeatKey = response.keyType == "premium" and key or nil,
		heartbeatTicket = response.keyType == "keyless" and response.adapterTicket or nil,
	}
end

local LimboSession = limboAuthorize()
local LimboHeartbeatScope = (getgenv and getgenv()) or _G
LimboHeartbeatScope.__LIMBO_ADAPTER_HEARTBEAT = type(LimboHeartbeatScope.__LIMBO_ADAPTER_HEARTBEAT) == "table"
	and LimboHeartbeatScope.__LIMBO_ADAPTER_HEARTBEAT or {}
local LimboAdapterHeartbeat = LimboHeartbeatScope.__LIMBO_ADAPTER_HEARTBEAT
LimboAdapterHeartbeat.Session = LimboSession




local function LimboKeyValidator(enteredKey)
    if type(enteredKey) ~= "string" or enteredKey == "" then return false end
    local cleanKey = enteredKey:gsub("%s", "")
    local player = LimboPlayers.LocalPlayer
    local robloxUserId = player and string.format("%.0f", player.UserId) or "0"

    local response, err = limboPostJson(LIMBO_VALIDATE_ENDPOINT, {
        key = cleanKey,
        robloxUserId = robloxUserId,
        deviceId = (getgenv and getgenv().gethwid and getgenv().gethwid()) or "clean_client",
    })

    if response and response.success then
        LimboSession.keyType = response.keyType
        LimboSession.needsKeyWindow = false
        print("[LIMBO HUB] Key validated successfully: " .. tostring(response.keyType))
        return true
    end
    return false
end

if LimboSession and LimboSession.source == "server_keyless" then
    print("[LIMBO HUB] Keyless access is active (server_keyless)")
elseif LimboSession and LimboSession.needsKeyWindow then
    print("[LIMBO HUB] Key required - showing KeySystem window")
else
    print("[LIMBO HUB] Session authorized: " .. tostring(LimboSession and LimboSession.keyType or "active"))
end


-- 3. Load Library
local Limbo = loadstring(game:HttpGet("https://raw.githubusercontent.com/KnullXDgt/Limbo-ui-Library/main/source.luau"))()

-- 4. Window Configuration
local WindowConfig = {
    Title                 = "Limbo Hub",
    Subtitle              = GAME_NAME,
    Version               = "v" .. VERSION,
    ShowExecutor          = true,
    Theme                 = "Darker",
    Center                = true,
    Draggable             = true,
    Resizable             = false,
    AutoScale             = true,
    ToggleButton          = true,
    Watermark             = "rbxassetid://74613200492285",
    WatermarkTransparency = 0.88,
    WatermarkSize         = 285,
    Icon                  = "rbxassetid://97957114633547",
}

if LimboSession and LimboSession.needsKeyWindow then
    WindowConfig.KeySystem = {
        Title = "Limbo Hub Access",
        Note = "Get a free key to start using Limbo Hub, or buy a premium key for instant access without the hassle",
        URL = LIMBO_GET_KEY_URL,
        SaveKey = true,
        KeyValidator = LimboKeyValidator,
    }
end

local Window = Limbo:CreateWindow(WindowConfig)
getgenv().LimboHub = Window

-- ============================================================
-- 5. CLEAN OOP API (Semua elemen otomatis tersimpan ke Config)
-- ============================================================

-- Tab 1: Information
local InfoTab = Window:AddTab("Information", "info")
InfoTab:AddParagraph({
    Title = "Join Our Community",
    Desc = "Become part of the Limbo Hub community on Discord for the latest updates, script support, and exclusive releases. Copy the invite link below and join us today!",
    Buttons = {
        {
            Title = "Copy Discord Link",
            FullWidth = true,
            Height = 26,
            Radius = 6,
            Callback = function()
                local copy = setclipboard or toclipboard
                if copy then
                    copy(DISCORD_INVITE)
                    Window:Notify({
                        Title = "Limbo HUB",
                        Content = "Discord link copied",
                        Delay = 2.5
                    })
                end
            end
        }
    }
})

-- Tab 2: Main Features
local MainTab = Window:AddTab("Main", "house")

-- Section 0: Fish Target Catalog
local FishCatalogSec = MainTab:AddSection("Fish Target (872 Fishes)", true)
FishCatalogSec:AddDropdown("Select Fish Target", "Pilih target ikan dari katalog (872 ikan)", ALL_FISH_NAMES, false, "1x1x1x1 Shark", function(val)
    -- aksi pemilihan target ikan
end)

-- Section 1: Support Features
local SupportSec = MainTab:AddSection("Support Features", true)
SupportSec:AddToggle("Auto Equip Rod", "Otomatis pegang pancingan saat tangan kosong", true, function(state) end)
SupportSec:AddToggle("Anti Drown", "Mencegah karakter tenggelam dan kehabisan oksigen", true, function(state) end)
SupportSec:AddToggle("Walk On Water", "Berjalan di atas permukaan air laut", false, function(state) end)
SupportSec:AddToggle("Freeze Character", "Mengunci posisi karakter agar tidak terseret arus", false, function(state) end)

-- Section 2: Auto Fishing (Legit Mode)
local FishingSec = MainTab:AddSection("Auto Fishing (Legit)", true)
FishingSec:AddToggle("Auto Cast", "Otomatis melempar umpan ke air", true, function(state) end)
FishingSec:AddToggle("Auto Reel", "Otomatis menarik pancingan saat ikan strike", true, function(state) end)
FishingSec:AddToggle("Auto Shake", "Otomatis menyelesaikan minigame goyangan", true, function(state) end)
FishingSec:AddSlider("Cast Delay", "Jeda waktu antara lemparan pancing (detik)", 0, 5, 1, function(val) end)

-- Section 3: Instant Catch Mode
local InstantSec = MainTab:AddSection("Instant Catch (Blatant)", false)
InstantSec:AddToggle("Instant Catch", "Menangkap ikan langsung seketika saat melempar", false, function(state) end)
InstantSec:AddSlider("Catch Delay", "Jeda tangkap instan (detik)", 0, 3, 0.5, function(val) end)

-- Section 4: Auto Sell Items
local SellSec = MainTab:AddSection("Auto Sell Items", false)
SellSec:AddToggle("Auto Sell", "Otomatis menjual ikan dan hasil tangkapan", false, function(state) end)
SellSec:AddDropdown("Sell Mode", "Pilih metode penjualan otomatis", {"Delay Mode", "Inventory Count"}, false, "Inventory Count", function(mode) end)
SellSec:AddInput("Sell Target Count", "Jumlah ikan di tas sebelum auto sell", "100", function(val) end)

-- Section 5: Craft Minigame
local CraftSec = MainTab:AddSection("Craft Minigame", false)
CraftSec:AddToggle("Auto Perfect Craft", "Otomatis menyelesaikan minigame craft 100% perfect", false, function(state) end)
CraftSec:AddSlider("Craft Delay", "Jeda klik perfect craft (detik)", 0.05, 0.5, 0.1, function(val) end)

-- Tab 3: Teleport
local TeleportTab = Window:AddTab("Teleport", "map-pin")
local WaypointSec = TeleportTab:AddSection("Waypoints", true)
WaypointSec:AddDropdown("Select Location", "Pilih pulau atau lokasi teleportasi", {
    "Spawn Point",
    "Moosewood Island",
    "Roslit Bay",
    "Sunken Ship",
    "Ancient Jungle"
}, false, "Spawn Point", function(loc) end)

-- Tab 4: Settings
local SettingsTab = Window:AddTab("Settings", "settings")
local SettingsSec = SettingsTab:AddSection("Safety & Performance", true)
SettingsSec:AddToggle("Anti AFK", "Mencegah kick 20 menit dari Roblox", true, function(st) end)
SettingsSec:AddToggle("Potato Graphics", "Menghapus partikel dan render berat untuk hemat RAM", false, function(st) end)

-- 6. Show Window (Instant Orvion Gen 2 style)
Window:Show()

print(("%s %s Version %s Loaded"):format(LIMBO_TAG, GAME_NAME, VERSION))

Window:Notify({
    Title   = "Limbo HUB",
    Content = string.format("%s  %s", GAME_NAME, VERSION),
    Icon    = "rbxassetid://97957114633547",
    Delay   = 4,
})
