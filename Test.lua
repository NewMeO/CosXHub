_G.Configs = {
    -- 📋 GENERAL SETTINGS
    ['White Screen'] = false, -- ปิด/เปิดจอขาว (เพื่อเพิ่มประสิทธิภาพ)
    ['Limit Plant'] = 150, -- จำกัดจำนวนต้นไม้ในฟาร์ม
    ['Collect Time'] = { -- เวลาในการเก็บเกี่ยว ขึ้นกับจำนวนเงินที่มี
        { Money = 100000, Minutes = 10 },
        { Money = 0, Minutes = 1 }
    },

    -- 🌾 PLANTING & SEED SETTINGS
    ['Open Seed Pack'] = true, -- เปิด Seed Pack อัตโนมัติ
    ['Seeds'] = { -- รายชื่อเมล็ดที่ต้องปลูกสำหรับเงินไม่ถึงที่ Event MoneyEnough
        "Tomato",
        "Coconut"
    },

    -- 🌾 CLEAR PLANTS
    ['Remove Plants'] = false,
    ['Ignore Plants'] = {
        "Tomato",
        "Apple"
    },

    -- 🐣 EGG SETTINGS
    ['Place Egg'] = true, -- วางไข่อัตโนมัติในฟาร์ม
    ['Hatch Egg'] = true, -- ฟักไข่อัตโนมัติ
    ['Eggs'] = { -- รายชื่อไข่ที่จะวางและซื้อ
		"Common Summer Egg",
		"Zen Egg",
        "Paradise Egg",
		"Bug Egg",
    },

    -- PET SETTING
    ['Auto Feed'] = true,
    ['Upgrade Max Equip'] = false,
    ['Upgrade Max Egg'] = true,

    ['Pet For Upgrade'] = { -- รายชื่อสัตว์สำหรับเอาไปฟาร์มเวลและเอาไปอัพเกรด
        "Starfish",
    },

    ['Pet For Sell'] = {
        "Dog",
        "Bunny",
        "Golden Lab",
        "Seagull",
        "Crab",
        "Raptor",
        "Triceratops",
        "Stegosaurus",
        "Pterodactyl",
        "Parasaurolophus",
        "Iguanodon",
        "Pachycephalosaurus",
        "Caterpillar",
        "Snail",
        "Giant Ant",
        "Squirrel",
        "Red Giant Ant"
    },

    -- ⚙️ GEAR SETTINGS
    ['Gears'] = { -- รายชื่อ Gear ที่ต้องการซื้อ
        "Master Sprinkler",
        "Godly Sprinkler",
        "Advanced Sprinkler",
        "Basic Sprinkler"
    },

    -- 🎉 EVENT SETTINGS
    ['Event MoneyEnough'] = 100000, -- เริ่มทำ Event เมื่อเงิน ≥ จำนวนที่กำหนด
    ['RestockEvent'] = true,
    ['RestockCost'] = 8388608000000,
    ['Event Shop'] = {
        "Zen Seed Pack",
        "Zen Egg"
    }
}

loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/4ca922e1b51a45b8058659e8096a7e1d.lua"))()
