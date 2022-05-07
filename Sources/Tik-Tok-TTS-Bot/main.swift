import Swiftcord

let bot = Swiftcord(token: "token")

bot.addListeners(TikTok())

bot.connect()
