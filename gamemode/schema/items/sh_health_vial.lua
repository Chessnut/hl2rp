ITEM.name = "Health Vial"
ITEM.category = "Medical"
ITEM.desc = "A small vial with green liquid."
ITEM.model = Model("models/healthvial.mdl")
ITEM.useSound = "items/medshot4.wav"
ITEM:AddQuery("on use: give 25 health")
ITEM.price = 40